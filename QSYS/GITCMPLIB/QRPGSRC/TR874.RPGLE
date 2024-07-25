      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR874     Trax Merged Routes maintenance - Delete
     *  28 December, 2011
     *  Retha Davis
     *
     *  Revisions
     *    12/28/11  RBD  6.40
     *      - Created.
     *
700aA*    01/08/16  RBD  7.00
     *      - Added call to TR811.
     *
710aA*    03/23/17  RBD  7.10a
     *      - Changed version from length 2 to 3.
     *
710bA*    11/18/17  DAS  7.10b
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Foptions   if   e           k disk
     Fpiruser   if   e           k disk
     Frtehed    if   e           k disk
     Fttmerg    uf   e           k disk
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
710bA*----------------------------------------------------------------
710bA*  *TRAX2  -  More TRAX options
710bA*----------------------------------------------------------------
710bA*
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
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pprti                22     26
     D  $pcrti                27     31
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Key definitions

     D keyop           ds                  likerec(oprec : *key)

     *----------------------------------------------------------------
     *  Variables
     *
     D $emp#           s              5
     D $msgf           s             10
     D error           s              1
     D url             s            100A   varying
     D whse30          s              3  0
710bAD dirLen          s              3  0

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
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     ttmrec                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = '0'
     C                   delete    ttmrec
     C                   exsr      zzxml
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     *   Call user added initialization routine.
     *
JSLaAC                   call      'GETCLIENT'
JSLaAC                   parm                    client           10
JSLaAC                   parm                    clientloc        10
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete corresponding records.
     *
     C     zzdel         begsr
     C                   eval      error = '0'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pprti
     C                   kfld                    $pcrti
     *
     *  Define key for Trax route file.
     *
     C     ttrky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pcrti
     *
     C                   eval      whse30 = $pwhse
     *
     C                   exsr      getOptions
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     ttmcrt        $md(19)
     C                   movea     $pcrti        $md(25)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXML    Delete xml for route deleted from merge if it exists.
     *
     *           Build new xml for route deleted if it's been exported.
     *
     *           Call TR873 to delete xml for the remaining parent
     *           and/or child routes, and create a new xml if all of
     *           the remaining parent and child routes have been
     *           exported.
     *
     C     zzxml         begsr
     *
     C                   eval      ifilnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $pcrti
     C                                + '_RTE.XML'
      /free

         select;

710bA      when optdir <> '';
710bA        dirLen = %len(%trimr(optdir));
710bA        if %subst(optdir:1:1) <> '/';
710bA          url = '/' + optdir;
710bA        else;
710bA          url = optdir;
710bA        endif;
710bA        if %subst(optdir:dirLen:1) <> '/';
710bA          url = %trimr(url) + '/';
710bA        endif;

           when optert = 'PROD';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTrax/';
JSLaA        else;
               url = '/BFCTrax/';
JSLaA        endif;

           when optert = 'TEST';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTraxTest/';
JSLaA        else;
               url = '/BFCTraxTest/';
JSLaA        endif;

           when optert = 'DEV ';
             url = '/BFCTraxDev/';

         endsl;


         ppath = %trimr(url) + %trim(ifilnam);
         callp(e) chkifsobj (ppath:pauth);
         if not %error;
           iDir = url;
           ifsrmvfil(iDir : iFilnam : iReturn : iMessage);
         endif;

710aD    // ifilnam = 'W' + %triml(%editc($pwhse:'X')) + 'R' + $pcrti
710aD    //         + '_V13_RTE.XML';
710aM    ifilnam = 'W' + %triml(%editc($pwhse:'X')) + 'R' + $pcrti
710aM            + '_V013_RTE.XML';
700aA    ppath = %trimr(url) + %trim(ifilnam);
700aA    callp(e) chkifsobj (ppath:pauth);
700aA    if not %error;
700aA      iDir = url;
700aA      ifsrmvfil(iDir : iFilnam : iReturn : iMessage);
700aA    endif;

      /end-free
     *
     C     ttrKy         chain     rtehed
     C                   if        %found(rtehed) and rhstat = '6'
     C                   eval      usemp# = 0
     C     ttrKy         chain     ttrte
     C                   if        %found
     C     ttrusr        chain     piruser
     C                   endif
     C                   move      usemp#        $emp#
     C                   call      'TR810'
     C                   parm                    whse30
     C                   parm                    $pcrti
     C                   parm                    $emp#
     C                   parm      ' '           $filsn           30
     C                   parm      ' '           $prtn
     C                   parm      ' '           $perm

700aAC                   call      'TR811'
700aAC                   parm                    whse30
700aAC                   parm                    $pcrti
700aAC                   parm                    $emp#
700aAC                   parm      ' '           $filsn           30
700aAC                   parm      ' '           $prtn
700aAC                   parm      ' '           $perm

     *      Prevent ZMQMSG routine from executing.
     C                   if        $prtn = '*OK'
     C                   eval      $prtn = ' '
     C                   endif
     C                   endif

     C                   call      'TR873'
     C                   parm                    whse30
     C                   parm                    $pprti
     C                   parm                    $prtn
     C                   parm                    $perm

     C                   endsr
     *----------------------------------------------------------------

      /free

       //---------------------------------------------------------------
       //  getOptions    Get options
       //---------------------------------------------------------------

        begsr getOptions;

       //  get *TRAX options

         keyop.opWhse = whse30;
         keyop.opCode = '*TRAX   ';

         chain %kds(keyop) Options;

         if not %found;
         opdat2 = ' ';
         else;
         opdat2 = opdata;
       endif;

710bA  //  get *TRAX2 options
710bA
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

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Trax Merged Route
