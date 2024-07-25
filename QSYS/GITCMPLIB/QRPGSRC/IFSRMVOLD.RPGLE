      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  IFSRMVOLD   Remove old entries from IFS directory
     *  20 October 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    10/20/07  DAS  5.10
     *      - Created.
     *
510aA*    10/31/07  DAS  5.10a
     *      - Revised not to die upon an error.
     *      - Changed activation group to *CALLER.
     *      - Removed setting on *INLR.
     *
520 A*    05/14/09  RBD  5.20
     *      - Fix: set #pgmq to QSYSOPR if blank when PUTMSGE called.
     *
700aA*    06/30/15  NLK  7.00
     *      - Add: unlink/delete only if able to open/close=not locked
     *
700bA*    09/28/16  RBD  7.00b
     *      - Enh: added Trax training routes file.  Don't delete object
     *        from BFCTrax dir if it's a Trax training route.
     *
710aA*    11/09/17  RBD  7.10a
     *      - Don't delete "Company" object from BFCTrax dir, it's a
     *        static object which holds company name, ip addy, etc.
     *
720aA*    12/07/17  RBD  7.20a
     *      - Revised to look for 'Trax' in dir parm passed in
     *        regarding Trax training routes, as Trax dir is now
     *        softcoded in *Trax2 options.
     *
720bA*    01/12/18  RBD  7.20b
     *      - Fix: had to revise 710a logic, only check for 'Company'
     *        if filename field length is 7, before fix it crashed when
     *        filename was less than 7.  All because filename is a
     *        variable length field. As a side note I think the only
     *        reason it doesn't crash when checking for 'W' plus whse
     *        is because if pos 1 is not 'W' it moves on.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      -Add CLient code
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------
     * File Specs
     *
700bAFtttrain   if   e           k disk
     *
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h
700bAD/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D getwhse         pr                  extpgm('GETWHSE')
      * Input
     D   puser                        8    const
     D   pWhse                        3  0 const

     *----------------------------------------------------------------
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

700aAD ifd             S             10I 0
700aAD iflags          S             10U 0
700bAD #whse           s              3  0
700bAD #pwhse          s              3  0
700bAD rteid           s              5
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
510dAD currdatestamp   s               z
510dAD datestamp       s               d
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
     *      $PDATE  Date (yyyymmdd)
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
     C                   parm                    $pDate            8 0
     C                   parm                    $pReturn          8
     C                   parm                    $pMessage        60

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

700bAC                   exsr      zzinz2

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
510aDC**                 callp     die(%trim(errmsg))
510aAC                   goto      bottom
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

700bA* If dir = BFCTrax
700bA /free
700bA    if %subst($pdir:1:8) = '/BFCTrax'
JSLaA        or %subst($pdir:1:8) = '/JSLTrax'
720aA        or %subst($pdir:5:4) = 'Trax';

700bA      if %subst(filename:1:1) = 'W'
700bA         and #whse = %dec(%subst(filename:2:3):3:0);

700bA        rteid = %subst(filename:6:5);
700bA        chain (#whse: rteid) tttrain;

700bA        //  Don't remove Trax training route
700bA        if %found;
700bA          iter;
700bA        endif;

700bA      endif;

710aA      //  Don't remove Company object
720bA      //  Skip this check if filename less than 7 long
720bA      if %len(filename) < 7;
720bA        iter;
720bA      endif;
710aA      if %subst(filename:1:7) = 'Company';
710aA        iter;
710aA      endif;

700bA    endif;
700bA /end-free

     *    Skip directories

     c                   if        S_ISDIR(st_mode)
     c                   iter
     c                   endif

     *    Calculate last data madification date

     c     epoch         adddur    st_mtime:*S   modtime
     c                   adddur    utcoffset:*S  modtime
     c                   move      modtime       mydate
     C                   eval      modymd = %dec(
     C                                      %char(mydate:*iso0):
     C                                      8 : 0)

     *    Delete file if old.

     C                   if        modymd < $pDate
     C                   exsr      zzunlink
     c                   endif

     C                   enddo

     C                   callp     closedir(dir)

510aAC     bottom        tag
510aDC**                 eval      *inlr = *on
510aAC                   return

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

     *
JSLaAC                   call      'GETCLIENT'
JSLaAC                   parm                    client           10
JSLaAC                   parm                    clientloc        10
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

520 AC                   if        #pgmq = *blanks
520 AC                   eval      #pgmq = 'QSYSOPR'
520 AC                   endif

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

700bA*----------------------------------------------------------------
700bA*  zzinz2 - Extra program initialization.  Called from mainline.
700bA*----------------------------------------------------------------

700bA /free
700bA  begsr zzinz2;

         // Get warehouse for user
         getwhse(#user:#pwhse);
         #whse = #pwhse;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZUNLINK  Unlink (Delete) File from Directory.
700aA*            Unlink (Delete) only if not already open.
     *----------------------------------------------------------------

     C     zzunlink      begsr

700aAc                   eval      iflags = o_rdonly + o_share_none
700aAc                   eval      ifd = open(%trimr(fnwithdir):iflags)
700aAc                   if        ifd >= 0
700aA
700aA*      Close Import Data file to allow unlink/delete
700aAc                   callp     close(ifd)

     C                   if        unlink(fnwithdir) < 0
     C                   callp     errno
     C                   eval      errmsg = fnwithdir
     C                   exsr      zm0138
     C                   endif
700aA
700aAc                   endif

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
