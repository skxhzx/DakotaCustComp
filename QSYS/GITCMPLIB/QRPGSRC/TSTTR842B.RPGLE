710 AH dftactgrp( *NO )
     H   actgrp( *NEW )
     H bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTTR842B   Search for files in given IFS Directory with specific strings passed
     *  Kenneth Elder                                   t
     *
710 A*    03/29/18  KDE  7.20
     *      - Created
     *
     *----------------------------------------------------------------
     f*  Files

     D/copy QCOPYSRC,IFSIO_H

     D* Local Variables
     d @command        s            350
710bAD bfcoffset       s              3  0 inz(0)
     D cmtRecord       S           2048
     D crlf            C                   const(x'0d25')
710bAd crtDate         s               z
710bAD CurrStamploc    s               z
710bAD CurrStampsys    s               z
710bAD CurrStampuc     s               z
710bAD CurrStampmn     s             26
     D dh              s               *
     D Dict            s             11
     d dlmtor          s              4
     D drnam           s            640
     D dspnam          s             50
     d pCommand        s             30
     d pEmpNo          s              5
     d pFile           s            100
710bAD pMessage        s             99
     d pPath           s            100
     d pRtid           s              5
     d pRtnCode        s             10
     d pVersion        s              5
     d pWhse           s              3  0
     d  pStop          s              5
     d  pStamp         s             19
     d  pLatitude      s             15
     d  pLongitude     s             15
     d  pRtnMsg        s             60
     D rc              s             10i 0
710bAD ucOffset        s              3  0

     d lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
     d upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0

     D @__errno        pr              *   extproc( '__errno' )
     D strerror        pr              *   extproc( 'strerror' )
     D    errnum                     10i 0 value
     D errno           pr            10i 0

710bA***    Used to Get time stamp values
710bAd GetCurrStamp    pr

710bAD GetMicroTime    pr
710bAD  $pmicrouc                      z
710bAD  $pmicrolocal                   z

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     d TR842           pr                  extpgm('TR842')
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3  0
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMsg                      60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      iPath       IFS Directory
     *      iFilter     File Filter
     *
     *----------------------------------------------------------------

     d tsttr842b       pr                  extpgm('TSTTR842B')
     d  iPath                        20
     d  iType                         1
     d  iFilter                      10

     d tsttr842b       pi
     d  iPath                        20
     d  iType                         1
     d  iFilter                      10

      /free

        if %parms() < 3;
          dsply 'tsttr842B (/path/ (S/R) filter)';
          return;
        endif;

       // clear flat text file and append this html to flat file
710bA  GetCurrStamp();
       pMessage = '*OK';

       //  Open directory

       dh = opendir( %trim(iPath) ) ;
       if  dh = *NULL ;
          pMessage = 'opendir: ' + %str( strerror( errno ) ) ;
          *inlr = *ON ;
          return ;
       endif ;

       //  Read each entry from the directory (in a loop)

       p_dirent = readdir( dh ) ;
       dow  p_dirent <> *NULL ;

          drnam = %str( %addr( d_name ) ) ;
          drnam = %xlate(lowercase:uppercase:drnam);
          // Ensure files not ending with V020_CMP.XML
          if %len(%trim(drnam)) < 12;
             // skip since it cannot end with above string based on length
             pMessage = 'Entry not ending with V020_CMP.XML';
          else;
710bM        if %subst(drnam:%len(%trim(drnam))-11:
                           %len(%trim(drnam))) = 'V020_CMP.XML';
                if iFilter <> *blanks;
                   if %len(%trim(drnam)) > %len(%trim(iFilter));
710bM                 if %subst(drnam:1:
                         %len(%trim(iFilter))) <> %trim(iFilter);
                         pMessage = 'Entry not equal to passed Filter';
                      endif;
                   else;
                      pMessage = 'Entry not equal to passed Filter';
                   endif;
                endif;
             else;
                pMessage = 'Entry not ending with V020_CMP.XML';
             endif;
          endif;

          if pMessage = '*OK' and %scan('S':drnam) <> 0 and iType <> 'S';
            pMessage = 'Entry not a Completed Stop';
          endif;

          if pMessage = '*OK' and %scan('S':drnam) = 0 and iType <> 'R';
            pMessage = 'Entry not a Completed Route';
          endif;

          // if pMessage remains as *OK then call TR842
          if pMessage = '*OK';

             // call TR842
             pVersion = '20';
             if %scan('S':drnam)<>0;
                pCommand = 'postCompletedStop';
             else;
                pCommand = 'postCompletedRoute';
             endif;
             pWhse    = %dec(%subst(%trim(drNam):2:3):3:0);
             pRtid    = %subst(%trim(drNam):6:5);
             pFile    = %trim(drNam);
             pPath    = iPath;
             pEmpNo   = '99999';

             tr842(pVersion: pCommand: pEmpNo: pWhse: pRtid: pStop: pPath:
                   pFile: pStamp: pLatitude: pLongitude: pRtnCode: pRtnMsg);

             if pRtnCode <> '*OK';
             endif;
             dspnam=drnam;
             //dsply %trim(dspnam);
          endif;

          p_dirent = readdir( dh ) ;
          pMessage = '*OK';

       enddo;

       //  Close the directory
       rc = closedir( dh ) ;
       *inlr = *ON ;
       return ;

710bA /end-free

      * Retrieve the error number for UNIX-type APIs

     P errno           b
     D errno           pi            10i 0
     D p_errno         s               *
     D wwreturn        s             10i 0 based( p_errno )
     C                   eval      p_errno = @__errno
     c                   return    wwreturn
     P                 e

710bA*----------------------------------------------------------------
710bA*  GetCurrStamp  Get current timestamps
710bA*----------------------------------------------------------------
710bA
710bAp GetCurrStamp    b
710bAd GetCurrStamp    pi
710bA
710bA /free
710bA
710bA    getmicrotime(currstampuc:currstampsys);
710bA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
710bA    currstamploc = currstampsys + %hours(bfcoffset);
710bA
710bA /end-free
710bA
710bAp GetCurrStamp    e
