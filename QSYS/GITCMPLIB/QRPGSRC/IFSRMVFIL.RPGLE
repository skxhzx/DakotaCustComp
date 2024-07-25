      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSRMVFIL   Remove/delete (unlink) file from IFS directory.
     *
     *  If you want to overlay an existing xml file with new records,
     *  see o_trunc in TR810 ... the o_trunc clears the file before
     *  writing to it.
     *
     *  29 July 2010
     *  Retha Davis
     *
     *  Revisions
     *
530 A*    07/29/10  RBD  5.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

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
     *  Working Variables
     *----------------------------------------------------------------

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

     D error           S               n
     D forever         S               n
     D currdatestamp   s               z
     D datestamp       s               d
     D dir             s               *
     D dirLen          S              3  0
     D pos             S              3  0
     D dirName         S           2048A   varying
     D fnwithdir       S           2048A   varying
     D filename        S           2048A   varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PDIR   IFS directory
     *      $PNAME  File name
     *
     *    Returned Parameters
     *      $PReturn
     *      $PMessage
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdir           640
     C                   parm                    $pName           25
     C                   parm                    $pReturn          8
     C                   parm                    $pMessage        60

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

     *  Strip off ending '/' from directory

     C                   eval      dirName = %trim($pDir)
     C                   eval      dirLen = %len(%trim(dirName))
     C                   if        %subst(dirName:dirLen:1) = '/'
     C                   eval      dirName = %subst(dirName:1:dirLen-1)
     C                   eval      dirLen = %len(%trim(dirName))
     C                   endif

     *  Open directory

     C                   eval      dir = opendir(''
     C                                   + dirName
     C                                   + '')

     *  Open Import directory failed, get out.

     C                   if        dir = *NULL
     C                   eval      error  = *on
     C                   eval      $pReturn = '*ERROR'
     C                   eval      $pMessage = 'See QSYSOPR messages'
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

     c                   eval      filename = %subst(d_name:1:d_namelen)
     c                   eval      fnwithdir = dirName + '/' + filename
     c                   if        stat(fnwithdir: %addr(mystat)) < 0
     c                   iter
     c                   endif

     *    Skip directories

     c                   if        S_ISDIR(st_mode)
     c                   iter
     c                   endif

     *    Delete file if old.

     C                   if        filename = $pName
     C                   exsr      zzunlink
     C                   leave
     c                   endif

     C                   enddo

     C                   callp     closedir(dir)

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     C*******************************************
     C* get the number of seconds between local
     C* time an Universal Time Coordinated (UTC)
     C*******************************************
     c                   callp(e)  CEEUTCO(hours_utc: mins_utc: secs_utc)
     c                   if        %error
     c                   eval      utcoffset = 0
     c                   else
     c                   eval      utcoffset = secs_utc
     c                   endif

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
     *  ZZUNLINK  Unlink (Delete) File from Directory.
     *----------------------------------------------------------------

     C     zzunlink      begsr

     c                   callp     unlink(filename)
     C                   if        unlink(fnwithdir) < 0
     C                   callp     errno
     C                   eval      errmsg = fnwithdir
     C                   exsr      zm0138
     C                   endif

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
     c                   if        dirmode = 16384
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
