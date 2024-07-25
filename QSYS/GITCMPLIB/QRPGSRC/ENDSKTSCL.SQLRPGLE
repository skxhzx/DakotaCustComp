      /copy pirvoice/qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*CALLER)

     *----------------------------------------------------------------
     * Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *---------------------------------------------------------------*
     *                                                               *
     *   ENDSKTSCL   End BFCSKTSCL client program                    *
     *   23 January 2014                                             *
     *   Kenneth Elder                                               *
     *                                                               *
     *   Revisions                                                   *
     *                                                               *
     *     01/23/14  KDE  6.20                                       *
     *       - Created                                               *
710 A*     07/12/17  KDE  7.10
     *       - Recompile because file Scale changed
     *                                                               *
     *---------------------------------------------------------------*

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V4R4M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(BTS)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     H bnddir('QC2LE':'QUSAPIBD')

    F*----------------------------------------------------------------
    F*  File Specs
    F*----------------------------------------------------------------
     Fbfcscllog O    E           K Disk
     Fscale     if   e           k disk

     *------------------------------------------------------------------
     * Variables ...
     *------------------------------------------------------------------
     D  dqdata         s           1024
     D  dqkeylen       s              3  0 inz(36)
     D  dqlen          s              5  0
     D  dqorder        s              2
     D  dqwait         s              5  0
     d  dqname         s             10
     d  dqlib          s             10

     Ddqkey            ds            19
     D dqwhse                         3p 0
     D dqScale                       15
     D dqDemo                         1

     *==================================================================
     * Main Line
     *==================================================================

     C     *Entry        PList
     C                   parm                    #port             5

      /free
          // Ensure proper Options for SQL
            exec sql
              set Option Commit=*none, Dlyprp=*Yes,
                         Closqlcsr = *ENDMOD;
      /end-free

      *
      *  Send Data Queue statement to close opened socket client
      *
     c                   exsr      sndDtaq

     C     Bottom        Tag
     C                   Eval      *INLR = *On
     C                   Return
500cA*----------------------------------------------------------------
500cA*  sndDTAQ    Send Close Command to test
500cA*----------------------------------------------------------------
500cA
500cAC     sndDTAQ       begsr

     c/exec sql
     c+ select scwhse,scid,scdemo
     c+   into :dqkey
     c+   from scale
     c+   where scport = :#port
     c/end-exec

     c                   if        SQLSTT = '00000'
     c*
     c*  shutdown the normal client for a given tcpip port tied to scale
     c*  or demo port
     c                   eval      dqname = 'SCALES'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqdata = '*shutdown'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqlen = %len(%trim(dqdata))

     C                   call      'QSNDDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c*
     c*  shutdown the server client for a demo id the port is marked as
     c*  a demo port
     c                   if        dqdemo = 'Y'
     c                   eval      dqname = 'SCALESERV'
     c                   eval      dqlib = '*LIBL'
     c                   eval      dqdata = '*shutdown'
     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqlen = %len(%trim(dqdata))

     C                   call      'QSNDDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey
     c                   endif
     c                   endif

     c                   endsr
