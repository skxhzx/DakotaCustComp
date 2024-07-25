      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSTOMCLN   Clean up TOMCAT history
     *  24 June 2015
     *  Nancy Koelz
     *
     *  Revisions
     *
     *    06/24/15  NLK  7.00
     *      - dCommand values *BFCSYS or *blanks when called
     *      - Created--For Now Hard Code 14 days clean up
     *                 incoming dCommand if *BFCSYS Tomcat* else Tomcat6036*
     *                 IFSTOMCLN loops the /root dir and IFSRMVOLD loops the files inside
     *
730aA*    04/25/19  NLK  7.30a
     *      - incoming dCommand if *BFCSYS Tomcat* else Tomcat7082*
     *        IFSTOMCLN loops the /root dir and IFSRMVOLD loops the files inside
     *      - Add if US Foods - /Tomcat7062USFCluster/logs
     *
     *----------------------------------------------------------------

730aA /COPY QCOPYSRC,ID#USFCORP

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h

     D S_ISDIR         PR             1N
     D   mode                        10U 0 value

     D CEEUTCO         PR                  ExtProc('CEEUTCO')
     D   hours                       10I 0
     D   minutes                     10I 0
     D   seconds                      8F

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D                 ds
     D errmsg                  1    512

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     D #msgid          s              7
     D #msgk           s              4
     D #msgkey         s              4  0
     D #msgtp          s              7
     D #pgmq           s             10

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D cmpdte          pr                  extpgm('CMPDTE')
     D  cmd                           8    const
     D  prg                          10    const
     D  whse                          3    const
     D  date                          8

     D getclient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

     D ifsrmvold       pr                  extpgm('IFSRMVOLD')
     D  dir                         640    const
     D  date                          8  0 const
     D  return                        8
     D  message                      60

     *----------------------------------------------------------------
     *
     * Data structure
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D iDated          s               d
     D iDateda         s             10

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pCommand        s             10

     D dDate           s              8
     D dPath           s            640
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D Subdir1         c                   const('/logs              ')
     D Subdir2         c                   const('/BFCDakota/logs    ')
     D Subdir3         c                   const('/BFCDakotaTest/logs')
     D Tomcat6036      c                   const('TOMCAT6036')
730a D Tomcat7082      c                   const('TOMCAT7082')
730a D Tomcat7062      c                   const('TOMCAT7062')
     D TomcatBFC       c                   const('TOMCAT    ')
     D mystat          S                   like(statds)
     D epoch           S               Z   inz(z'1970-01-01-00.00.00.000000')
     D modtime         S               Z
     D modymd          s              8  0
     D mydate          S               D
     D mytime          S               T
     D hours_utc       s             10I 0
     D mins_utc        s             10I 0
     D secs_utc        s              8F
     D utcoffset       s             10I 0
     D worktime        S              8A
     D dir             s               *
     D dirName         S           2048A   varying
     D dirPath         S           2048A   varying
     D fnwithdir       S           2048A   varying
     D rootname        S           2048A   varying

     D iDir            s            640
     D iDate           s              8  0
     D iReturn         s              8
     D iMessage        s             60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCommand   Command Parm to determine what we are running
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCommand         10

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
      /free
        *inlr = *on;

        // Compute cut off date

        dDate = '*DFT';
        cmpdte ('*TOMCAT' : 'IFSTOMCLN' : pCommand : dDate);

        // Convert date into number

        monitor;
          iDate = %dec(dDate:8:0);
        on-error;
          return;
        endmon;

        // Create IFS path (LOOP)
        // IFSTOMCLN loops the /root dir and IFSRMVOLD loops the files inside

        exsr zapath;


        return;

        //-------------------------------------------------------------
        //       Subroutines in Alphabetical Order
        //-------------------------------------------------------------

        //-------------------------------------------------------------
        //  *inzsr  Initialization subroutine
        //-------------------------------------------------------------

        begsr *inzsr;

          //  Get client id

          getclient(client : clientloc);

        endsr;

      /end-free
     *----------------------------------------------------------------
     *      Put Path together to call IFSRMVOLD
     *----------------------------------------------------------------

     C     zapath        begsr
     *  Root-start with  '/' for directory

     C                   eval      dirName = '/'

     *  Open directory

     C                   eval      dir = opendir(''
     C                                   + dirName
     C                                   + '')

     *  Open Import directory failed, get out.

     C                   if        dir = *NULL
     C                   eval      error  = *on
     C                   eval      errmsg = %trim(%editc(errno:'4'))
     C                                   + ' - '
     C                                   + %str(strerror(errno))
     C                   eval      #pgmq    = 'QSYSOPR'
     C                   exsr      zm0105
     C                   eval      errmsg = 'opendir('
     C                                    + %trim(dirName)
     C                                    + '): '
     C                                    + %str(strerror(errno))
     C                   exsr      zm0105
     C**                 callp     die(%trim(errmsg))
     C                   goto      bottom
     C                   endif

     * Process Directory

     c                   eval      p_statds = %addr(mystat)

     C                   dow       forever = forever
     C                   eval      p_dirent = readdir(dir)
     C                   if        p_dirent = *null
     C                   leave
     C                   endif

     *    Get file name and information.

     c                   eval      rootname = %subst(d_name:1:d_namelen)
     c                   eval      fnwithdir = dirName + rootname
     c                   if        stat(fnwithdir: %addr(mystat)) < 0
     c                   iter
     c                   endif

     *    Skip directories NOT HERE - Skip non Directories (rev in pr)

     c                   if        S_ISDIR(st_mode)
     c                   iter
     c                   endif


     *    If rootname is Tomcat*, we may need to run clean up
     *    d_namelen needed since rootname is a variable length and maynot allow chk of Tomcat value

     c     lower:upper   xlate     rootname      rootname
     c                   if        pCommand = '*BFCSYS   ' and d_namelen >= 6
     c                   if        %subst(rootname:1:6) = TomcatBFC
     c                   eval      dPath = fnwithdir + Subdir1
     c                   exsr      zaRmv
     c                   eval      dPath = fnwithdir + Subdir2
     c                   exsr      zaRmv
     c                   eval      dPath = fnwithdir + Subdir3
     c                   exsr      zaRmv
     c                   endif
     c                   endif

     c                   if        pCommand = *blanks and d_namelen >= 10
     c                   if        %subst(rootname:1:10) = Tomcat6036
730aAc                             or %subst(rootname:1:10) = Tomcat7082
730aAc                             or client = usfcorp
730aAc                             and %subst(rootname:1:10) = Tomcat7062
     c                   eval      dPath = fnwithdir + Subdir1
     c                   exsr      zaRmv
     c                   eval      dPath = fnwithdir + Subdir2
     c                   exsr      zaRmv
     c                   eval      dPath = fnwithdir + Subdir3
     c                   exsr      zaRmv
     c                   endif
     c                   endif

     C                   enddo

     C                   callp     closedir(dir)
     C     bottom        tag
     C                   return
     C                   endsr

     *----------------------------------------------------------------
     *      zacall - Call IfsRmvOld files from directory being passed
     *----------------------------------------------------------------
     C     zaRmv         begsr
      /free
        iDir = dPath;
        ifsrmvold(iDir : iDate : iReturn : iMessage);
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *      0105  - Generic message id (50 character data field)
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0138  - Error deleting files. Manual cleanup required.
     *----------------------------------------------------------------

     C     zm0138        begsr
     C                   eval      #msgid = 'PIR0138'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZMPMSG  Send Message to FTP Import Message Queues.
     *----------------------------------------------------------------

     C     zmpmsg        begsr

     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif

     C                   if        #pgmq = *blanks
     C                   eval      #pgmq = 'QSYSOPR'
     C                   endif

     C                   eval      #msgkey = #msgkey + 1
     C                   eval      #msgk   = %editc(#msgkey:'X')

     C                   call      'PUTMSGE'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk

     C                   endsr


     *----------------------------------------------------------------
     *  s_isdir
     *----------------------------------------------------------------

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This tests a file mode to see if a file is a directory.
      *
      * Here is the C code we're trying to duplicate:
      *      #define _S_IFDIR    0040000                                       *
      *      #define S_ISDIR(mode) (((mode) & 0370000) == _S_IFDIR)
      *
      * 1) ((mode) & 0370000) takes the file's mode and performs a
      *      bitwise AND with the octal constant 0370000.  In binary,
      *      that constant looks like: 00000000000000011111000000000000
      *      The effect of this code is to turn off all bits in the
      *      mode, except those marked with a '1' in the binary bitmask.
      *
      * 2) ((result of #1) == _S_IFDIR)  What this does is compare
      *      the result of step 1, above with the _S_IFDIR, which
      *      is defined to be the octal constant 0040000.  In decimal,
      *      that octal constant is 16384.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P S_ISDIR         B
     D S_ISDIR         PI             1N
     D   mode                        10U 0 value

     D                 DS
     D  dirmode                1      4U 0
     D  byte1                  1      1A
     D  byte2                  2      2A
     D  byte3                  3      3A
     D  byte4                  4      4A

     C* Turn off bits in the mode, as in step (1) above.
     c                   eval      dirmode = mode

     c                   bitoff    x'FF'         byte1
     c                   bitoff    x'FE'         byte2
     c                   bitoff    x'0F'         byte3
     c                   bitoff    x'FF'         byte4

     C* Compare the result to 0040000, and return true or false.
     C* slight change:::::
     C* now just the opposite - I want directories and not files ***
     C*                              chg = to <>
     c                   if        dirmode <> 16384
     c                   return    *On
     c                   else
     c                   return    *Off
     c                   endif
     P                 E

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
