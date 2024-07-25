     H/COPY *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Compile at V4R5M0 until all clients are V5R1 or later.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  BFCFTP      BFC FTP Program
     *  20 July 2004
     *  Dave Sommerville
     *
417 A*    07/20/04  DAS  4.17
     *      - Created
     *
500 A*    08/25/05  MLB  5.00
     *      - Enh: Added code to program that ignores NAMEFMT, BINARY
     *        errors during processing unless return code < 0.
     *      - Revised program to build return string if errors occur
     *        during PUT, GET processing when return code < 0.
500aA*    11/21/05  MLB  5.00a
     *      - Enh: Added code to add new program Action; A=Append to
     *        allow existing file to be added to.
500bA*    12/23/05  MLB  5.00b
     *      - Fix: Revised program to swap parameters on the FTP_Append
     *        procedure call.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V4R5M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*NEW)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Assumptions
     *
     *   - This program creates a new activation group to run in so
     *     that the ftp session value can be retained and not shared
     *     with other programs.
     *   - A Library and File name will be sent together. The member
     *     name is optional.
     *   - When a Library and File are sent, the string will be created
     *     by this program.
     *   - The File Type will be sent with the Library and File name.
     *   - The Binary, NameFmt and Passive flags will be set when the
     *     command is *ALL or *ACTION.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

    H  bnddir('BFCFTPBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D/copy qcopysrc,p.ftpapi

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D ftp             S             10I 0
500 AD ftpreturn       S             10I 0
500 AD ftpreturn16p    S             16P 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd      - *ALL    - Connect, signon, action, quit
     *                   *ACTION - action only
     *                   *QUIT   - quit only
     *      $pserver   - Remote FTP server.
     *      $puser     - User
     *      $ppwd      - Password
     *      $pbin      - Binary mode (Y,N)
     *      $pnamefmt  - Name format (0,1)
     *      $ppassive  - Passive mode (Y,N)
     *      $paction   - Action (P=Put,G=Get)
500aA*                          (A=Append)
     *      $pfiletype - File type (i.e., file, savf).
     *      $pfromlib  - From library
     *      $pfromfile - From file
     *      $pfrommbr  - From member
     *      $pfromstr  - From string
     *      $ptolib    - To library
     *      $ptofile   - To file
     *      $ptombr    - To member
     *      $ptostr    - To string
     *
     *    Returned Parameters
     *
     *      $preturn   - *OK, *ERROR.
     *      $pmessage  - Message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pserver         65
     C                   parm                    $puser           30
     C                   parm                    $ppwd            30
     C                   parm                    $pbin             1
     C                   parm                    $pnamefmt         1
     C                   parm                    $ppassive         1
     C                   parm                    $paction          1
     C                   parm                    $pfiletype        4
     C                   parm                    $pfromlib        10
     C                   parm                    $pfromfile       10
     C                   parm                    $pfrommbr        10
     C                   parm                    $pfromstr        65
     C                   parm                    $ptolib          10
     C                   parm                    $ptofile         10
     C                   parm                    $ptombr          10
     C                   parm                    $ptostr          65
     C                   parm                    $preturn         10
     C                   parm                    $pmessage        60

     c                   eval      $preturn = '*OK'
     c                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Verify command

     c                   if        $pcmd <> '*ALL'
     c                             and $pcmd <> '*CONNECT'
     c                             and $pcmd <> '*ACTION'
     c                             and $pcmd <> '*QUIT'
     c                   eval      $pmessage = 'Invalid command sent'
     c                                       + '(' + %trim($pcmd) + ')'
     c                   goto      bottom
 E01 c                   endif

     *  Log to joblog

500 Dc*                  callp     ftp_log(*On)
500 Mc                   eval      ftpreturn = ftp_log(*On)

     *  Connect

     c                   if        $pcmd = '*ALL' or $pcmd = '*CONNECT'
     c                   eval      ftp = ftp_conn(%trim($pserver):
     c                                            %trim($puser):
     c                                            %trim($ppwd))
 B01 c                   if        ftp < 0
     c                   eval      $pmessage = ftp_error
     c                   goto      bottom
 E01 c                   endif
 E01 c                   endif

     *  Set namefmt

     c                   if        $pcmd = '*ALL' or $pcmd = '*ACTION'
     c                   select
     c                   when      $pnamefmt = '0'
500 Dc*                  if        ftp_namfmt(ftp: 0) < 0
500 Ac                   eval      ftpreturn16p = ftp_namfmt(ftp: 0)
500 Ac                   if        ftpreturn < 0
     c                   eval      $pmessage = ftp_error
     c                   callp     ftp_quit(ftp)
     c                   goto      bottom
     c                   endif
     c                   other
500 Dc*                  if        ftp_namfmt(ftp: 1) < 0
500 Ac                   eval      ftpreturn16p = ftp_namfmt(ftp: 1)
500 Ac                   if        ftpreturn < 0
     c                   eval      $pmessage = ftp_error
     c                   callp     ftp_quit(ftp)
     c                   goto      bottom
     c                   endif
     c                   endsl
     c                   endif

     *  Set passive mode.

     c                   if        $pcmd = '*ALL' or $pcmd = '*ACTION'
     c                   if        $ppassive = 'N'
500 Dc*                  callp     ftp_passiv(*off)
500 Ac                   eval      ftpreturn = ftp_passiv(*off)
     c                   else
500 Dc*                  callp     ftp_passiv(*on)
500 Ac                   eval      ftpreturn = ftp_passiv(*on)
     c                   endif
     c                   endif

     *  Set binary flag

     c                   if        $pcmd = '*ALL' or $pcmd = '*ACTION'
     c                   if        $pbin = 'N'
500 Dc*                  callp     ftp_binary(*off)
500 Ac                   eval      ftpreturn = ftp_binary(*off)
     c                   else
500 Dc*                  callp     ftp_binary(*on)
500 Ac                   eval      ftpreturn = ftp_binary(*on)
     c                   endif
     c                   endif

     *  Do action

     c                   if        $pcmd = '*ALL' or $pcmd = '*ACTION'

     *    See if string needs to be created.

     c                   if        $pfromlib <> ' ' or $ptolib <> ' '
     c                   exsr      crtstrings
     c                   endif

     *    Now, do action.

     c                   select

     *    Put

     c                   when      $paction = 'P'

500 Dc*                  if        ftp_put(ftp:
500 Ac                   eval      ftpreturn = ftp_put(ftp:
 B01 c                                     %trim($pfromstr):
500 Mc                                     %trim($ptostr))
500 Dc*                                    %trim($ptostr))<0
500 Ac                   if        ftpreturn < 0
     c                   eval      $pmessage = ftp_error
     c                   callp     ftp_quit(ftp)
     c                   goto      bottom
     c                   endif

     *    Get

     c                   when      $paction = 'G'

500 Dc*                  if        ftp_get(ftp:
500 Ac                   eval      ftpreturn = ftp_get(ftp:
 B01 c                                     %trim($pfromstr):
500 Mc                                     %trim($ptostr))
500 Dc*                                    %trim($ptostr))<0
500 Ac                   if        ftpreturn < 0
     c                   eval      $pmessage = ftp_error
     c                   callp     ftp_quit(ftp)
     c                   goto      bottom
     c                   endif

500aA
500aA*    Append file
500aA
500aAc                   when      $paction = 'A'
500aA
500aAc                   eval      ftpreturn = ftp_append(ftp:
500bMc                                     %trim($ptostr):
500bMc                                     %trim($pfromstr))
500bDc*                                    %trim($pfromstr):
500bDc*                                    %trim($ptostr))
500aAc                   if        ftpreturn < 0
500aAc                   eval      $pmessage = ftp_error
500aAc                   callp     ftp_quit(ftp)
500aAc                   goto      bottom
500aAc                   endif
500aA
     c                   endsl
     c                   endif

     *  Quit session

     c                   if        $pcmd = '*ALL' or $pcmd = '*QUIT'
     c                   callp     ftp_quit(ftp)
     c                   endif

     c     bottom        tag
     c                   if        $pmessage <> ' '
     c                   eval      $preturn = '*ERROR'
     c                   endif
     c                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  crtstrings  Create strings from Library/File names
     *----------------------------------------------------------------

     c     crtstrings    begsr

     *  Format From string

     c                   if        $pfromlib<>' '

     c                   select

     *    When Namefmt is '0'

     c                   when      $pnamefmt = '0'
     c                   eval      $pfromstr = %trim($pfromlib)
     c                                       + '/' + %trim($pfromfile)
     c                   if        $pfrommbr <> ' '
     c                   eval      $pfromstr = %trim($pfromstr) + '.'
     c                                       + %trim($pfrommbr)
     c                   endif

     *    Otherwise, assume Namefmt '1'

     c                   other
     c                   eval      $pfromstr = '/qsys.lib/'
     c                                       + %trim($pfromlib) + '.lib/'
     c                                       + %trim($pfromfile) + '.'
     c                                       + %trim($pfiletype)
     c                   if        $pfrommbr <> ' '
     c                   eval      $pfromstr = %trim($pfromstr) + '/'
     c                                       + %trim($pfrommbr) + '.mbr'
     c                   endif
     c                   endsl

     c                   endif

     *  Format To string

     c                   if        $ptolib<>' '

     c                   select

     *    When Namefmt is '0'

     c                   when      $pnamefmt = '0'
     c                   eval      $ptostr = %trim($ptolib)
     c                                     + '/' + %trim($ptofile)
     c                   if        $ptombr <> ' '
     c                   eval      $ptostr = %trim($ptostr) + '.'
     c                                     + %trim($ptombr)
     c                   endif

     *    Otherwise, assume Namefmt '1'

     c                   other
     c                   eval      $ptostr = '/qsys.lib/'
     c                                     + %trim($ptolib) + '.lib/'
     c                                     + %trim($ptofile) + '.'
     c                                     + %trim($pfiletype)
     c                   if        $ptombr <> ' '
     c                   eval      $ptostr = %trim($ptostr) + '/'
     c                                     + %trim($ptombr) + '.mbr'
     c                   endif
     c                   endsl

     c                   endif

     c                   endsr
