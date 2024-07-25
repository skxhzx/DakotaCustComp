      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR873   Trax - Delete and rebuild xml files for merged routes.
     *
     *  30 December 2011
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/30/11  RBD  6.40
     *      - Created.
     *
700aA*    01/08/16  RBD  7.00a
     *      - Added call to TR811 to create version 1.3 Trax(c) xml.
     *
710aA*    11/18/17  DAS  7.10a
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *----------------------------------------------------------------
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Foptions   if   e           k disk
     Fpiruser   if   e           k disk
     Frtehed    if   e           k disk
     Fttmerg1   if   e           k disk
     Fttrte     if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D ifsrmvfil       pr                  extpgm('IFSRMVFIL')
     D  dir                         640    const
     D  filnam                       25
     D  return                        8
     D  message                      60

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A
     D  authority                    10A

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *
     * Data structure
     *
     D opdat2          ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  opten2               117    117
710aA*----------------------------------------------------------------
710aA*  *TRAX2  -  More TRAX options
710aA*----------------------------------------------------------------
710aA*
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
     *    OPTV12  -  Default = N.  Y = create V1.2 xml.
     *    OPTV20  -  Default = N.  Y = create V2.0 xml.
     *    OPTDIR  -  IFS main directory
     *
     * Data structure
     *
     D opdta3          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
     D  optv12                18     18
     D  optv20                19     19
     D  optdir                20     39
     D  opten3               117    117
     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D $emp#           s              5
     D exported        s              1
     D first           s              1
     D lastStop        s              2  0
     D url             s            100A   varying
710aAD dirLen          s              3  0

     *----------------------------------------------------------------
     *  Date/time variables

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        s               d
     D edittime        s               t   timfmt(*hms:)
     D micro           s             26
     D micro4          s              4
     D timestamp       s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions

     D keyop           ds                  likerec(oprec : *key)

     *----------------------------------------------------------------
     *  Constants

     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D iDir            s            640
     D iFilnam         s             25
     D iReturn         s              8
     D iMessage        s             60

     D  ppath          s            640A
     D  pauth          s             10A

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Parent route ID
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     * Main line

     C                   eval      $prtn = '*OK    '
     C                   exsr      getOptions

     *  Get route header status for parent route

     C     rteKy         chain     rtehed
     C                   if        %found(rtehed)
     C                             and rhstat = '6'
     C                   eval      exported = *on
     C                   else
     C                   eval      exported = *off
     C                   endif

     *  Look for parent route xml file, if found, delete it.

     C                   eval      ifilnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     C                                + '_RTE.XML'
      /free

         select;

710aA      when optdir <> '';
710aA        dirLen = %len(%trimr(optdir));
710aA        if %subst(optdir:1:1) <> '/';
710aA          url = '/' + optdir;
710aA        else;
710aA          url = optdir;
710aA        endif;
710aA        if %subst(optdir:dirLen:1) <> '/';
710aA          url = %trimr(url) + '/';
710aA        endif;

           when optert = 'PROD';
JSLaA      if client = JSilvert;
JSLaA        url = '/JSLTrax';
JSLaA      else;
             url = '/BFCTrax/';
JSLaA      endif;

           when optert = 'TEST';
JSLaA      if client = JSilvert;
JSLaA        url = '/JSLTraxTest';
JSLaA      else;
             url = '/BFCTraxTest/';
JSLaA      endif;

           when optert = 'DEV ';
             url = '/BFCTraxDev/';

         endsl;

         ppath = %trimr(url) + %trim(ifilnam);
         callp(e) chkifsobj (ppath:pauth);
         if not %error;
           iDir = url;
           ifsrmvfil(iDir : iFilnam : iReturn : iMessage);
         endif;

      /end-free

     *  Loop through Trax merged routes and delete xml, if found, for
     *  child routes.

     C     rteKy         setll     ttmerg1
     C                   dou       forevr <> forevr
     C     rteKy         reade     ttmerg1
     C                   if        %eof(ttmerg1)
     C                   leave
     C                   endif
     C                   if        rhstat <> '6'
     C                   eval      exported = *off
     C                   endif

     C                   eval      ifilnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + ttmcri
     C                                + '_RTE.XML'
      /free


         ppath = %trimr(url) + %trim(ifilnam);
         callp(e) chkifsobj (ppath:pauth);
         if not %error;
           iDir = url;
           ifsrmvfil(iDir : iFilnam : iReturn : iMessage);
         endif;

      /end-free
     C                   enddo

     *  Create new xml if parent and all child routes have been exported.

     C                   if        exported = *on
     C                   eval      usemp# = 0
     C     rteKy         chain     ttrte
     C                   if        %found
     C     ttrusr        chain     piruser
     C                   endif
     C                   move      usemp#        $emp#
     C                   call      'TR810'
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $emp#
     C                   parm      ' '           $filsn           30
     C                   parm      ' '           $prtn
     C                   parm      ' '           $perm
     *
700aAC                   call      'TR811'
700aAC                   parm                    $pwhse
700aAC                   parm                    $prtid
700aAC                   parm                    $emp#
700aAC                   parm      ' '           $filsn           30
700aAC                   parm      ' '           $prtn
700aAC                   parm      ' '           $perm
     *      Prevent ZMQMSG routine from executing.
     C                   if        $prtn = '*OK'
     C                   eval      $prtn = ' '
     C                   endif
     *
     C                   endif

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define key for RTEHED and TTMERG1 files

     C     rteKy         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
JSLaAC                   call      'GETCLIENT'
JSLaAC                   parm                    client           10
JSLaAC                   parm                    clientloc        10
     *
     C                   endsr
     *-------------------------------------------------------------------------

      /free

       //---------------------------------------------------------------
       //  getOptions    Get options
       //---------------------------------------------------------------

        begsr getOptions;

       //  get *TRAX options

         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX   ';

         chain %kds(keyop) Options;

         if not %found;
         opdat2 = ' ';
         else;
         opdat2 = opdata;
       endif;

710aA  //  get *TRAX2 options
710aA
         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX2  ';

         chain %kds(keyop) Options;

         if not %found;
           opdta3  = ' ';
         else;
           opdta3  = opdata;
         endif;

       endsr;

      /end-free

     *-------------------------------------------------------------------------
