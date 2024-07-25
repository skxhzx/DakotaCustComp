     H copyright('(c) Copyright BFC Software, Inc - 2006')
     H dftactgrp(*NO)
     H actgrp('BFCSCLSRV')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)

      *----------------------------------------------------------
      * Copyright (C) 2006 BFC Software, Inc. - All Rights Reserv
      * BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *   BFCSCLSRV  BFC Socket Server Program to act as Scale De
      *
      *   Data queue processes were removed.  This is a very simp
      *   process that serves Demo purposes only.  In live enviro
      *   an actual scale would serve this purpose and act as the
      *   This program will not only make the connection but also
      *   any of the back and forth communication
      *
      *   16 May 2014
      *   Kenneth Elder
      *
      *   Revisions
      *
      *     05/16/14  KDE  6.50
      *       - Copied from BFCSKTSRV in PIRVOICE
700  *     11/08/16  KDE  7.00
     *       - Include SQL compile parms within SQL Set in Calcs
710 A*     07/12/17  KDE  7.10
     *       - Recompile because files Scale, PRDLBHIST and UCISPLITS changed
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  Compile instructions
      *
      *    Just use option 14 from PDM.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  Assumptions:
      *
      *   - Records are comma delimited and end with a CR/LF.
      *   - Only one request record should be sent to this progra
      *       at a time.
      *   - Any characters following a CR are ignored because we
      *       only looking for a single request record.
      *   - One or more records can be returned by this program a
      *       determined by the request.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Binding Directories
      *----------------------------------------------------------
     H bnddir('QC2LE':'QUSAPIBD':'PIRVBNDDIR':'BFCBND')

      *----------------------------------------------------------
      *  File Specs
      *----------------------------------------------------------
     Fbfcsclsrv o    e           k disk

      *----------------------------------------------------------
      * Function prototypes.
      *----------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     D qrcvdtaq        PR                  extpgm('QRCVDTAQ')
     D  dqname                       10
     D  dqlib                        10
     D  dqlen                         5  0
     d  dqdata                     1024
     d  dqwait                        5  0
     d  dqorder                       2
     d  dqkeylen                      3  0
     d  dqkey                        15
     d  dqsnd                         3  0
     d  dqsndinfo                    50

      *----------------------------------------------------------
      *  Standard communication information data fields
      *----------------------------------------------------------

      /Copy qcopysrc,r#cominfo
      *----------------------------------------------------------
      *  Socket prototypes, constants and variables.
      *----------------------------------------------------------
      /copy qcopysrc,$SocketsH
      /copy qcopysrc,$SignalH
      *----------------------------------------------------------
      * Buffers ...
      *----------------------------------------------------------

     D  bufferdef      s           1024a
     D  buffersize     c                   const(%len(bufferdef))

     D  #bufferinds    ds
     D   #sbufferin                        like(bufferdef)
     D   #bufferin                    1a   dim(buffersize)
     D                                     Overlay(#sBufferIn)
      *
      * #BufferPrvDS - Previous buffer to prevent blowing out log file
     D  #BufferPrvDS   DS
     D   prvBuffer                         Like(BufferDef)
      *
      * #BufferWrkDS - Incoming request string - work fields
     D  #BufferWrkDS   DS
     D   #sBufferWrk                       Like(BufferDef)
      *
      * #BufferShlDS - Previous Send Request saved
     D  #BufferShlDS   DS
     D   #sBufferShl                       Like(BufferDef)

     D  #bufferoutds   ds
     D   #sbufferout                       like(bufferdef)
     D   #bufferout                   1a   dim(buffersize)
     D                                     Overlay(#sBufferOut)

      *----------------------------------------------------------
      * Definitions for Select routines
      *----------------------------------------------------------

      *   Current maximum of active socket numbers
     D CurMax          S             10I 0
      *   Sockets flags - active/inactive ('1'/'0')
     D SckFlags        S              1A   Dim(20)
      *   Pointer to the socket description bit set (readset)
     D FD_Set@         S               *   Inz(%Addr(FD_Set))
      *   Wait time in seconds for select function
     D WaitTime        Ds
     D  Seconds                      10I 0 Inz(120)
     D  MicroSec                     10I 0 Inz(0)

      *----------------------------------------------------------
      * Misc tables and arrays
      *----------------------------------------------------------
     D  a40            s              1    dim(40)

      *----------------------------------------------------------
      * CSV fields
      *----------------------------------------------------------

     D  csvrecinds     ds
     D   csvrecin                          like(bufferdef)
     D   csvaryin                     1a   dim(buffersize)
     D                                     Overlay(CSVRecIn)

     D  csvrecoutds    ds
     D   csvrecout                         like(bufferdef)
     D   csvaryout                    1a   dim(buffersize)
     D                                     Overlay(CSVRecOut)

      *----------------------------------------------------------
      * Constants ...
      *----------------------------------------------------------
     D   cr            c                   const(x'0D')
     D   crlf          c                   const(x'0D25')
     D   crlfcrlf      c                   const(x'0D250D25')
     D   eof           c                   const(x'00')
     D   lf            c                   const(x'25')
     D   lfcrlf        c                   const(x'250D25')
     D   forever       c                   const('1')
     *
     *  Data Structure to hold previous log buffer to prevent
     *     repeating command from scale server
     *
     D                 ds
     D aryBuffer                   8192    dim(8)
     D  prvSnd                     1024a   overlay(aryBuffer:*next)
     D  prvRcv                     1024a   overlay(aryBuffer:*next)
     D  prvSel                     1024a   overlay(aryBuffer:*next)
     D  prvCl1                     1024a   overlay(aryBuffer:*next)
     D  prvCl2                     1024a   overlay(aryBuffer:*next)
     D  prvOpn                     1024a   overlay(aryBuffer:*next)
     D  prvEwb                     1024a   overlay(aryBuffer:*next)
     D  prvEr                      1024a   overlay(aryBuffer:*next)

      *----------------------------------------------------------
      * Misc defs ...
      *----------------------------------------------------------

     D begstamp        s               z
     D curstamp        s               z
     D curtime         s              6  0
     D convwgt         s              9  2
     D Bit             s             10P 0
     DreturnStatus     S             10I 0
     D curipaddr       s             15
     D curport         s              5  0
     D connectAgain    s               n   inz(*off)
     D error           s              1    inz('0')
     D i               s             10P 0
     D ii              s             10P 0
     D j               s             10P 0
     D jj              s             10P 0
     D loop            s             10P 0
     D**tlsec          s              5  0

     D  dqdata         s           1024
     D  dqkeylen       s              3  0 inz(36)
     D  dqlen          s              5  0
     D  dqorder        s              2
     D  dqwait         s              5  0
     d  dqname         s             10
     d  dqlib          s             10

417bADdqkey            ds            17
417bAD dqwhse                         3p 0
417bAD dqScale                       15

417bADoutkey           ds            36
417bAD otwhse                         3p 0
417bAD otScale                       15
     D otStation                      2
     D otDemo                         1
     D otWeight                       9p 3
     D otUom                          2
     D otport                         5  0

     D  shutdown       s              9

      *----------------------------------------------------------
      *  Time variables
      *----------------------------------------------------------

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

      *----------------------------------------------------------
      *  Program information data structure.
      *----------------------------------------------------------

      *Copy qcopysrc,v#pgminfds

      *----------------------------------------------------------
      * Begin V#PGMINFDS - Voice Program information data structu
      *                    04/15/03  DAS  1.00  Created
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0

      *** End V#PGMINFDS ***

     C     *entry        plist
     C                   parm                    #portparm        15 5

      * Initialize sockets.

      /free
700 A       // Set SQL default parms
700 A       exec sql
700 A         set Option Commit=*none, Dlyprp=*Yes,
700 A                    Closqlcsr = *ENDMOD;
      /end-free

     C                   Exsr      getScale
     C                   Exsr      SktInit

      * Main Select processing loop

     C                   DoW       Forever = Forever
     c                   exsr      chkdtaq
     C                   eval      curipaddr = ' '
     C                   eval      curport   = 0

      *   Restore readset using the flag array
      *    Flag '1' sets on, flag '0' sets off

     C     0             Do        CurMax        J
     C                   If        SckFlags(J + 1) = '1'
     C                   CallP     FDSet(J: FDes)
     C                   Else
     C                   CallP     FDClr(J: FDes)
     C                   Endif
     C                   Enddo

      *   Select the sockets that connect or send data
      *    (deselect other sockets)


     C                   Eval      #uRC = Select(CurMax + 1
     C                                           : FD_Set@: *NULL: *NULL
     C                                           : %Addr(WaitTime) )

      *   If Select timed out - Restore readset and reenter the loop
      *     (there is no incoming request waiting)

     C                   If        #uRC = 0
     C                   Iter
     C                   Endif

      *   If Select was unsuccessful - End the server program
      *     (a programming error)
     c                   If        #uRC < 0
     c                   eval      perrno = $$Errno
     c                   eval      DspError = Errno
     c                   eval      pMessage = StrError(Errno)
     c                   eval      MsgToDsply = DspErrorA + ' ' +
     c                                   Message
     c                   eval      SlgTyp = 'Er2'
     c                   eval      SlgUrc = #uRC
     c                   eval      SlgBuf = SelectError
     c                   Exsr      WriteLog
     c                   eval      SlgBuf = MsgToDsply
     c                   Exsr      WriteLog
     c                   Eval      *InLR = *On
     c                   Return
     c                   Endif
     c*   Write record to log file.
     c
     c                   eval      SlgTyp = 'Sel'
     c                   eval      SlgUrc = #uRC
     c                   eval      SlgBuf = *Blanks
     c                   movea     SckFlags      SlgBuf
     c                   Exsr      WriteLog
     c
     c*    Inspection loop. Inspect all description bits in readset
     c*      up to the current maximum and process those which are set
     c*      on
     c
     c     0             Do        CurMax        Bit
     c
     c*      If a bit is off, move on to next one.
     c                   If        FDIsSet(Bit: FDes) = 0
     c                   Iter
     c                   Endif
     c
     c*       If the bit represents a listening socket - Accept a
     c*        Connect
     c*         Otherwise Receive and Process data
     c
     c                   Select
     c                   When      Bit = #Socket1
     c                   Exsr      SktAccept
     c                   Other
     c                   Eval      #Socket2 = Bit
     c                   Exsr      SktRead
     c                   Endsl
     C                   Enddo

     C                   Enddo

     C     bottom        tag

      *==========================================================
      *
      *  *InzSR     Program initialization subroutine.
      *
      *==========================================================
     C     *inzsr        begsr
     C                   endsr

      *==========================================================
      *  Socket routines
      *==========================================================


500cA*----------------------------------------------------------------
500cA*  chkDTAQ    Check Data Queue for shutdown Request
500cA*----------------------------------------------------------------
500cA
500cAC     chkDTAQ       begsr

     c                   eval      dqdata = ' '
     c                   eval      dqname = 'SCALESERV'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqScale = otScale
     c                   eval      dqwhse = otWhse

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
417bAC                   parm      'EQ'          dqorder
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c                   parm                    dqsnd             3 0
     c                   parm                    dqsndinfo        50

     c                   if        dqlen <> 0
      *  if *shutdown record requested then close this socket demo server
     c                   if        %trim(dqdata) = '*shutdown'
     c                   exsr      doshutdown
     c                   endif
     c                   endif

     c     endrcvdtaq    endsr
      *----------------------------------------------------------
      *
      *  SktAccept  Accept client socket
      *
      *----------------------------------------------------------
     C     SktAccept     BegSr

      *   Try to accept the first client in queue
      *     and create a new client's socket

     C                   eval      SockAddr = *AllX'00'
     C                   eval      #iWork = %size(sockaddr)
     C                   eval      #Socket2 = Accept(#Socket1:
     C                                               %Addr(SockAddr):
     C                                             %Addr(#iWork))

      *   Check for error.

     C                   if        ( #Socket2 < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + '-' +
     c                               Message
      **   MsgToDsply    dsply
      **   AcceptError   dsply
     C                   eval      SlgTyp = 'Er3'
     C                   eval      SlgUrc = #Socket2
     C                   eval      SlgBuf = AcceptError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   eval      *INLR = *ON
     C                   return
     C                   endif
      *
      *   Write record to log file.
      *
     C                   eval      SlgTyp = 'Opn'
     C                   eval      SlgUrc = 0
     C**                 eval      SlgBuf = *Blanks
     C                   eval      curipaddr = %str(inet_ntoa(sa_addr))
     C                   z-add     sa_port       curport
     C                   eval      SlgBuf = 'IP: '
     C                                    + curipaddr
     C                                    + '  Listen Port: '
     C                                    + %char(#portparm)
     C                                    + '  Comm Port: '
     C                                    + %char(sa_port)
     C                   Exsr      WriteLog

      *  Set socket reuse option...

     C                   eval      #iRC = SetSockOpt(#Socket2:
     C                                               SOL_SOCKET:
     C                                               SOL_REUSEADDr:
     C                                               %Addr(OPTVAL):
     C                                               %Size(OPTVAL))

     C                   if        (#iRC < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + ' ' +
     c                               Message
     C                   eval      SlgTyp = 'Er8'
     C                   eval      SlgUrc = #iRC
     C                   eval      SlgBuf = SetSError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   eval      *INLR = *ON
     C                   return
     C                   endif

      *  Set nonblocked mode for the socket.

     C                   eval      #iRC = FCntl(#Socket2:
     C                                          F_SETFL:
     C                                          O_NONBLOCK)

      *   Accept OK - Add the socket to readset
      *     and set a new current maximum of used sockets

     C                   If        #Socket2 >= 0
     C                   CallP     FDSet (#Socket2: FDes)
     C                   Eval      SckFlags(#Socket2 + 1) = '1'

     C                   If        #Socket2 > CurMax
     C                   Eval      CurMax = #Socket2
     C                   Endif

     C                   Endif

     C                   Endsr

      *----------------------------------------------------------
      *
      *  SktClose2  Close Socket2
      *
      *----------------------------------------------------------
     C     SktClose2     BegSr

     C                   eval      #iWork = Close(#Socket2)

      *       Write log record.

     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + ' ' +
     c                               Message
     C**                 eval      SlgTyp = 'Cls'
     C                   eval      SlgUrc = #iwork
     C                   eval      SlgBuf = *Blanks
     C                   Exsr      WriteLog

      *       If the closed socket was the current maximum -
      *         - Find the nearest lower active socket
      *         - Make the highest active socket current maximum

     C                   If        #Socket2 = CurMax  And  #Socket2>0
     C                   Eval      J = #Socket2 - 1
     C                   DoW       SckFlags(J + 1) = '0'
     C                   Eval      J = J - 1
     C                   Enddo
     C                   Eval      CurMax = J
     C                   Endif

     C                   Endsr

      *----------------------------------------------------------
      *
      *  SktInit    Initialize server socket
      *
      *----------------------------------------------------------
     C     SktInit       BegSr

      *  Get socket descriptor...

     C                   eval      #Port = #PortParm

      *  Get socket descriptor...

     C                   eval      #Socket1 = Socket(AF_INET:
     C                                               SOCK_STREAM:
     C                                               PROTOCOL)
     C                   if        (#Socket1 < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + ' ' +
     c                               Message
      **   MsgToDsply    dsply
      **   SockError     dsply
     C                   eval      SlgTyp = 'Er4'
     C                   eval      SlgUrc = #Socket1
     C                   eval      SlgBuf = SockError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
      *
     C                   eval      *INLR = *ON
     C                   return
     C                   endif

      *  Set socket reuse option...

     C                   eval      #iRC = SetSockOpt(#Socket1:
     C                                               SOL_SOCKET:
     C                                               SOL_REUSEADDR:
     C                                               %Addr(OPTVAL):
     C                                               %Size(OPTVAL))

     C                   if        (#iRC < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + ' ' +
     c                               Message
      **   MsgToDsply    dsply
      **   SetSError     dsply
     C                   eval      SlgTyp = 'Er5'
     C                   eval      SlgUrc = #iRC
     C                   eval      SlgBuf = SetSError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   eval      *INLR = *ON
     C                   return
     C                   endif

      *  Bind to well-known socket...

     C                   eval      sin_family = AF_INET
     C                   eval      sin_addr = GetHostId
     C                   eval      sin_port = #Port
     C                   eval      #iRC = Bind(#Socket1:
     C                                         %Addr(ServerAddr):
     C                                         %Size(ServerAddr))
     C                   if        (#iRC < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + '-' +
     c                                 Message
      **   MsgToDsply    dsply
      **   BindError     dsply
     C                   eval      SlgTyp = 'Er6'
     C                   eval      SlgUrc = #iRC
     C                   eval      SlgBuf = BindError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   eval      *INLR = *ON
     C                   return
     C                   endif

      *  Listen...

     C                   eval      #iWork = 10
     C                   eval      #iRC = Listen(#Socket1:
     C                                           #iWork)

     C                   if        (#iRC < 0 )
     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + '-' +
     c                                Message
      **   MsgToDsply    dsply
      **   ListenError   dsply
     C                   eval      SlgTyp = 'Er7'
     C                   eval      SlgUrc = #iRC
     C                   eval      SlgBuf = ListenError
     C                   Exsr      WriteLog
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   eval      *INLR = *ON
     C                   return
     C                   endif

      *   Clear readset array

     C                   CallP     FDZero(FDes)
     C                   Eval      SckFlags = '0'

      *   Set on the listening socket in readset and in the flag

     C                   CallP     FDSet(#Socket1: FDes)
     C                   Eval      SckFlags(#Socket1 + 1) = '1'
     C                   Eval      CurMax = #Socket1

    c*     Clear Data Queue on startup for given
    c*     Warehouse and Port
    c*     Since multiple devices can feed this one
    c*     queue we look for the specific entries
    c*     keyed by the warehouse and scale on startup

     c                   eval      dqdata = ' '
     c                   eval      dqname = 'SCALESERV'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqScale = otScale
     c                   eval      dqwhse = otWhse

     c                   dow       forever = forever

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
417bAC                   parm      'EQ'          dqorder
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c                   parm                    dqsnd             3 0
     c                   parm                    dqsndinfo        50

    c*    if no remaining entries for this scale and port
    c*    then leave

     c                   if        dqlen = 0
     c                   leave
     c                   endif

     c                   enddo

     C                   Endsr

      *----------------------------------------------------------
      *
      *  SktRead    Read socket and process it.
      *
      *----------------------------------------------------------
     C     SktRead       BegSr

      *  Read the incoming requests until double CR/LF.

     C                   eval      CSVRecIn = *Blanks
     C                   eval      j = 0
     C                   eval      loop = 0
     C                   time                    BegStamp

     C                   dow       Forever = Forever
     C                   eval      loop = loop + 1

     C                   eval      #sBufferIn = *Blanks
     C                   eval      #BufferSz = BufferSize

     C                   Eval      #uRC = Recv(#Socket2:
     C                                         %Addr(#BufferIn):
     C                                         #BufferSz:
     C                                         0                )

      *    If #uRC = 0 the client has issued a close,
      *      if #uRC > BufferSize, an error has occured...

     C                   if        #uRC < 1 Or #uRC > BufferSize

      *       Write log record.

     C                   eval      perrno = $$Errno
     C                   eval      DspError = Errno
     C                   eval      pMessage = StrError(Errno)
     C                   eval      MsgToDsply = DspErrorA + ' ' +
     c                                Message
     C                   if        #uRC = 0
     C                   eval      SlgTyp = 'Cl1'
     C                   else
     C                   if        Errno = EWOULDBLOCK
     C                   if        loop < 10
     C                   iter
     C                   endif
     C                   time                    CurStamp
     C                   eval      ttlsec =
     C                             %diff(CurStamp:BegStamp:*SECONDS)
     C                   If        TtlSec < 5
     C                   eval      loop = 0
     C                   iter
     C                   EndIf
     C                   eval      SlgTyp = 'EWB'
     C                   else
     C                   eval      SlgTyp = 'Er1'
     C                   endif
     C                   endif
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = *Blanks
     C                   Exsr      WriteLog
     C                   if        SlgTyp = 'Er1'
     C                   eval      SlgBuf = MsgToDsply
     C                   Exsr      WriteLog
     C                   endif

      *       See if we should close the socket.

     C                   if        SlgTyp = 'Cls'
     C                             or SlgTyp = 'Er1'
     C                   eval      SlgTyp = 'Cl1'
     C                   exsr      sktclose2
     C                   EndIf

      *       If the closed socket was the current maximum -
      *         - Find the nearest lower active socket
      *         - Make the highest active socket current maximum
      *
     C                   leave
     C                   endif
      *
      *    Translate ASCII to EBCDIC...
      *
     C                   eval      #iWork5 = BufferSize
     C                   call      'QDCXLATE'
     C                   parm                    #iWork5
     C                   parm                    #sBufferIn
     C                   parm                    #AtoETabl
     C                   parm                    #XLateLib
      *
      *  Write record to log file.
      *
     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferIn
     C                   Exsr      WriteLog

      *    Extract records from input buffer and process them.

      *      Assumptions:

      *        - Each record ends with CRLF.
      *        - A request consists of one record.
      *        - A blank record (just CRLF), will not be sent with request.
      *        - A record is contained within a single Recv buffer.

      *      When a line feed character is found,
      *        process command and return repsonse

     C     1             do        #urc          i

     C                   if        #bufferin(i) <> lf
     C                             and #bufferin(i) <> cr
     C                   eval      j = j+1
     C                   eval      csvaryin(j) = #bufferin(i)
     C                   endif

     C                   if        #bufferin(i) = lf
     C                             or #bufferin(i) = cr
     C                             or j = buffersize
      *  either process request or jump out and end program
     c                   if        csvrecin = '*shutdown'
     c                   exsr      doShutDown
     c                   else
     c                   exsr      processCmd
     C                   eval      csvrecin = *blanks
     c                   eval      j = 0
     c                   leave
     C                   endif
     C                   endif

     C                   enddo

      *  leave after successful transaction
     c                   if        j = 0
     c                   leave
     c                   endif

     C                   enddo
      *  Close the connection if close comes from client

     c                   if        %subst(SlgTyp:1:2) = 'Cl'
     C                   eval      SlgTyp = 'Cl2'
     C                   exsr      SktClose2
     c                   endif

     C                   Endsr

      *-------------------------------------------------------
      *
      *  getScale
      *
     C     getScale      begsr
     c/exec sql
     c+ select scwhse,scid,scsta,scdemo,scdemowgt,scdemouom,scport
     c+   into :outkey
     c+   from scale
     c+   where scport = :#portparm
     c/end-exec
     c                   eval      otport = #portparm
     C                   endsr

      *==========================================================
      *  Misc routines
      *==========================================================

      *----------------------------------------------------------
      *
      *  #Write     Write buffer to socket
      *
      *----------------------------------------------------------
     C     #write        begsr
      *
      * Write subroutine . . .
      *
      *  Save buffer for log file.
      *
     C                   eval      slgbuf = %trimr(#sbufferout)
      *
      *  Write to the client...
      **                 Eval      #iWork5 = BufferSize
     C                   eval      #iwork5 = %len(%trimr(#sbufferout))
     C                   call      'QDCXLATE'
     C                   parm                    #iwork5
     C                   parm                    #sbufferout
     C                   parm                    #etoatabl
     C                   parm                    #xlatelib
      *
     C                   eval      #buffersz = %len(%trimr(#sbufferout))
     C                   eval      #urc = writesock(#socket2:
     C                                             %addr(#bufferout):
     C                                             #buffersz)
      *
      *  Write record to log file.
      *
     C                   eval      slgtyp = 'Snd'
     C                   eval      slgurc = #urc
     C                   exsr      writelog
      *
     C                   endsr

      *----------------------------------------------------------
      *
      *  DoShutDown  SHUTDOWN requested.
      *
     C     doshutdown    begsr
     C
     C                   eval      #iwork = close(#socket2)
     C                   eval      #iwork = close(#socket1)
      *                  Eval      *InLR = *On
     C                   eval      *inlr = *on
     C                   return
     C
     C                   endsr
      *----------------------------------------------------------
      *  getcurrstamp  Get current timestamps
      *----------------------------------------------------------

     C     getcurrstamp  begsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

      *----------------------------------------------------------
      *  processCMD  Process command from Scale client request
      *----------------------------------------------------------
     C     processCMD    begsr
      /free
                         select;
                 // received scale reset command
                 // return a scale identifier
                         when %subst(csvrecin:1:1) = '@';
                              #sBufferOut = ' I4 A "DEMO' +
                                   %editc(otport:'X') + '"'
                                 + crlf;
                         eval #sBufferWrk = #sBufferOut;

                 // received name command
                 // return a scale entered name
                         when %subst(csvrecin:1:3) = 'I12';
                              #sBufferOut = ' I12 A "' +
                                           otScale + '"'
                                          + crlf;
                        eval #sBufferWrk = #sBufferOut;

                // received scale weight command
                // return weight from scale record (scdemowgt)
                // this weight is updated when user clicks demo
                // weight buttons from screen
                        when %subst(csvrecin:1:2) = 'SI';
                             exsr getScale;
                             #sBufferOut = ' S S '
                              + %xlate(' ':'0':%editc(otweight:'3')) +
                                  otuom
                                 +crlf;
                       #sBufferWrk = #sBufferOut;
                       endsl;

                      exsr sndSocket;
      /end-free
     c                   endsr

      *----------------------------------------------------------
      *  SndSocket Send command to Scale
      *----------------------------------------------------------

     C     sndSocket     begsr

      *    Translate EBCDIC to ASCII ...
     C                   Eval      #sBufferShl = #sBufferOut
     C                   eval      #iwork5 = %len(%trim(#sBufferOut))
     C                   Call      'QDCXLATE'
     C                   Parm                    #iWork5
     C                   Parm                    #sBufferOut
     C                   Parm                    #EtoATabl
     C                   Parm                    #XLateLib

      *  send command to scale to retrieve Scale Id

     C                   Eval      #uRC = Send(#Socket2:
     C                                         %Addr(#BufferOut):
     C                                         #iwork5:
     c                                         0      )
     c                   if        #iwork5<0
     c                   eval      perrno = $$errno()
     c                   eval      pmessage = Strerror(errno)
      *  if this represents no data, but a signal interruption th
      *  check to see if a request to close exists in the data qu
     c                   eval      connectAgain = *on
     c                   endif
     C                   eval      SlgTyp = 'Snd'
     C                   eval      SlgUrc = #uRC
     C                   eval      SlgBuf = #sBufferWrk
     c                   exsr      WriteLog
     c     endSnd        endsr

      *----------------------------------------------------------
      *
      *  WriteLog    Write log record
      *
     C     writelog      begsr

      *
      *  determine if transaction is repeating from previous.  The scale
      *  process send weight requests over and over to keep weight updated
      *
     c                   select
     c                   when      slgTyp = 'Snd'
     c                   eval      prvBuffer = aryBuffer(1)
     c                   when      slgTyp = 'Rcv'
     c                   eval      prvBuffer = aryBuffer(2)
     c                   when      slgTyp = 'Sel'
     c                   eval      prvBuffer = aryBuffer(3)
     c                   when      slgTyp = 'Cl1'
     c                   eval      prvBuffer = aryBuffer(4)
     c                   when      slgTyp = 'Cl2'
     c                   eval      prvBuffer = aryBuffer(5)
     c                   when      slgTyp = 'Opn'
     c                   eval      prvBuffer = aryBuffer(6)
     c                   when      slgTyp = 'Ewb'
     c                   eval      prvBuffer = aryBuffer(7)
     c                   when      %subst(slgTyp:1:2) = 'Er'
     c                   eval      prvBuffer = aryBuffer(8)
     c                   endsl
      *
     C                   exsr      getcurrstamp

     C                   eval      slgts     = currstamploc
     C                   eval      slgucs    = currstampuc
     C                   eval      slguser   = #user
     C                   eval      slgjob    = #job
     C                   eval      slgjobnbr = #jobnbr

     C                   eval      slgsk2 = #socket2
     C                   eval      SlgIP  = curipaddr
     C                   eval      SlgPortL = #portparm
     C                   eval      SlgPortC = curport
     C                   select
     C                   when      slgtyp = 'Sel'
     C                             or slgtyp = 'Opn'
     C                             or slgtyp = 'Rcv'
     C                   eval      slgid  = ' '
     C                   other
     C                   endsl
     c                   if        slgBuf <> prvBuffer
     C                   write     slgrec
     c                   select
     c                   when      slgTyp = 'Snd'
     c                   eval      aryBuffer(1) = slgBuf
     c                   when      slgTyp = 'Rcv'
     c                   eval      aryBuffer(2) = slgBuf
     c                   when      slgTyp = 'Sel'
     c                   eval      aryBuffer(3) = slgBuf
     c                   when      slgTyp = 'Cl1'
     c                   eval      aryBuffer(4) = slgBuf
     c                   when      slgTyp = 'Cl2'
     c                   eval      aryBuffer(5) = slgBuf
     c                   when      slgTyp = 'Opn'
     c                   eval      aryBuffer(6) = slgBuf
     c                   when      slgTyp = 'Ewb'
     c                   eval      aryBuffer(7) = slgBuf
     c                   when      %subst(slgTyp:1:2) = 'Er'
     c                   eval      aryBuffer(8) = slgBuf
     c                   endsl
     c                   endif
     C
     C                   endsr
