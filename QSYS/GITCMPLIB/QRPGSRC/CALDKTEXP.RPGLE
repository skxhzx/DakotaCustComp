      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CALDKTEXP   Calculate Dakota Expiration Date
     *  10 March 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    03/10/17  LMC  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pErrMsg        s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDPCombo       s             20
     D  pWhse          s              3  0
     D  pItem          s             15
     D  pEntDate       s              8  0
     D  pdktExpd       s              8  0
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.clcdur2

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $cdCmd          s              8
     D $cdDatein       s              8  0
     D $cdTimein       s              6  0
     D $cdYears        s              3  0
     D $cdMonths       s              3  0
     D $cdDays         s              3  0
     D $cdHours        s              3  0
     D $cdMinutes      s              3  0
     D $cdSeconds      s              3  0
     D $cdDateout      s              8  0
     D $cdTimeout      s              6  0

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D pgm2close       s             10

     D dridept         s               n
     D dridesig        s               n
     D driitem         s               n
     D main3err        s               n
     D main3callerr    s               n
     D main3rtnerr     s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDPCombo    Dictionary/Program combo or calling program
     *      pWhse       Warehouse
     *      pItem       Item
     *      pDate       Entered Date
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *      pDktExp      Dakota Expiration Date
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDPCombo
     C                   parm                    pWhse
     C                   parm                    pItem
     C                   parm                    pEntDate
     C                   parm                    pdktExpd

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // Get Item to determine date type

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = pWhse;
         $itItem  = pItem;

         $dricommand = 'DRIITEM';
         $drisubcmd = '%GETALL';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $item;
         $dridata2 = $item2;
         $drireturn = '*OK';

         exsr zzzdrimain3;
         //driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                //$drireturn: $drimessage: $dridata: $dridata2);


         select;
           when %error;
             pErrMsg = 'Error occured calling DRIITEM '
                     + '('
                     + %trimr(#Job) + '/'
                     + %trimr(#JobNbr) + '/'
                     + %trimr(#user)
                     + ')';
             return;
           when $drireturn <> '*OK';
             pErrMsg = 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
             return;
         endsl;

         $item = $dridata;
         $item2 = $dridata2;

         // Is item date sensitive or Mfg dated
         select;
           when $immflg = 'Y';
             $cdcmd = '*ADD    ';
             $cddays = $immday - $imuday;
             clcdur2($cdcmd: pentdate: $cdtimein: $cdyears:
                     $cdmonths: $cddays: $cdhours: $cdminutes:
                     $cdseconds: $cddateout: $cdtimeout);
             pdktexpd = $cddateout;

           when $itflgd = 'Y';
             $cdcmd = '*SUB    ';
             $cddays = $imuday;
             clcdur2($cdcmd: pentdate: $cdtimein: $cdyears:
                     $cdmonths: $cddays: $cdhours: $cdminutes:
                     $cdseconds: $cddateout: $cdtimeout);
             pdktexpd = $cddateout;

           other;
         endsl;
         return;
      /end-free
     *----------------------------------------------------------------
     *  zzzdrimain3  Call DRIMAIN3
     *----------------------------------------------------------------

     C     zzzdrimain3   begsr
     C                   eval      main3err = *off
     C                   eval      main3callerr = *off
     C                   eval      main3rtnerr = *off

     C                   select
     C                   when      $dricommand = 'DRIITEM'
     C                   eval      driitem = *on
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = 'DRIITEM'
     C                   call(e)   'DRIMAIN3'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
601bDC**                 parm      #pgm          $driprogram
601bMC                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRIMAIN3'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
601bDC**                 parm      #pgm          $driprogram
601bMC                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      main3err = *on
     C                   eval      main3callerr = *on
     C                   eval      $drireturn  = 'CALLERROR'
     C                   eval      $drimessage = 'Error occured on call to '
     C                                         + 'DRIMAIN3'
     C                                         + '/' + %trim($drisubcmd)
     C                                         + ' from ' + #pgm

     C                   when      $drireturn <> '*OK'
     C                   eval      main3err = *on
     C                   eval      main3rtnerr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = 'DRIITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C     enddricop     endsr


