      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DDOPTSGET  Get DDOPTS file
     *  05 September 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    09/05/14  DAS  6.50
     *      - Created.
     *
700aA*    08/15/15  DAS  7.00
     *      - Removed colors. Colors now handled in a separate program
     *      - Removed jdk 1.4 option.
     *
700bA*    09/23/15  DAS  7.00b
     *      - Added new options.
     *
700cA*    12/15/15  DAS  7.00c
     *      - Added new options.
     *      - Added new type 'num'.
     *
710aA*    09/27/17  LMC  7.10a
     *      - Added new options BFC_MERGE_ITEM_DIFFERENT_ZONE
     *
740 A*    02/27/20  KDE  7.40
     *      - Added new options BFC_LOCATION_DISPLAY_PIECES
     *
750 A*    03/17/21  KDE  7.50
     *      - Determine if value should be displayed based on what
     *        version of Truckbuilder the client uses.  We send down
     *        a new json field "dsp" with value of Y or N
     *      - Add option "Merging zones into a single pallet" for
     *        DD2 only. Values will be (N=Not Aloowed  S-Keep separate
     *        by default  M=Merge by default)
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits a return variable to 2000 characters. To protect
     *   against needing more than 2000 characters, we will call this
     *   multiple times. The pCallNum field will identify the call
     *   number.
     *
     *   There is not a good way to know where we left off from a
     *   previous call, therefore we will rebuild the string from
     *   the beginning each time and return the 2000 characters that
     *   corresponds to the call number.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fddopts    if   e           k disk
     Ftrkcomp   if   e           k disk
     Ftrkcompclrif   e           k disk
750 Afoptions   if   e           k disk
     Fglosess   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCallNum    Call number
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *
     *    Returned Parameters
     *      pJSON       JSON String
     *
     *----------------------------------------------------------------

     D ddoptsget       pr                  extpgm('DDOPTSGET')
     D  pCallNum                      1p 0
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pJSON                      2000    varying

     D ddoptsget       pi
     D  pCallNum                      1p 0
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D full            s               n

     D debug1          s           1000    varying
     D debug2          s           1000    varying
     D debug3          s           1000    varying
     D debug4          s           1000    varying
     D debug5          s           1000    varying
     D debug6          s           1000    varying

     D currStr         s           6000    varying
     D errStr          s             50    varying
     D largeStr        s           6000    varying
     D prvStr          s           6000    varying

     D clr             s              7    varying
     D cod             s              1    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     D dsc             s            500    varying
700cAD min             s              5    varying
700cAD max             s              5    varying
     D opt             s             40    varying
     D txt             s             50    varying
     D typ             s             10    varying
     D val             s            400    varying
750 Ad dsp             s              1    varying
750 Ad dd2only         s              1    varying

     D startPos        s              5p 0
     D endPos          s              5p 0
     D outLen          s              5p 0
     D maxLen          s              5p 0
     D len             s              5p 0
     D remainLen       s              5p 0
750 Ad tbMode          s              1

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
750 A    dd2only='N';
750 A  //
750 A  // Determine what version of Truckbuilder being used
750 A  //
750 A    chain (pSessId) glosess;
750 A    if not %found(glosess);
750 A      gswhse=1;
750 A    endif;
750 A    chain (gswhse:'*FEATURE') options;
750 A    // S-Standard  E-Enhanced  B-Both
750 A    if %found(options);
750 A      tbMode = %subst(opdata:5:1);
750 A      if tbMode = *blanks;
750 A        tbMode = 'S';
750 A      endif;
750 A    else;
750 A      tbMode = 'S';
750 A    endif;

         // Initialize max lengths

         outLen = %size(pJSON) - 2;
         maxLen = %size(largeStr) - 2;

         // If call size greater than max length, get out

         if (pCallNum * outLen) > maxLen;
           pJSON = '';
           return;
         endif;

         // Initialize overflow string

         errStr = '{"opt":"OVRFLOW"}';

         // Build large string

         largeStr = '{"recs":[';
         delimiter = '';

         // Add the options to the string.
         // This is the order they will appear on the screen.

         exsr BFC_LOADING_SCREEN;
         exsr BFC_EXPAND_ITEM_SPLITS;
         exsr BFC_DD_TIPS;
         exsr BFC_MAX_CUBE_WARNING;
         exsr BFC_SPLIT_ITEM;
         exsr BFC_DD_REBUILD_ROUTE;
         exsr BFC_DD_PRINT_ROUTE;
         exsr BFC_DD_ITEM_SORT;
         exsr BFC_PRINT_BYPASS_DIALOG;
         exsr BFC_PRINT_COLOR;
         exsr BFC_PRINT_AFTER_DONE;
         exsr BFC_PRINT_STYLE;
         exsr BFC_PRINT_LAYOUT;
740aA    exsr BFC_DISPLAY_PRINTER;
         exsr BFC_DD_TRUCK_PALLETS;
740 A    exsr BFC_LOCATION_DISPLAY_PIECES;
         exsr BFC_PALLET_DISPLAY_PIECES;
         exsr BFC_STOP_DISPLAY_PIECES;
         exsr BFC_ITEM_DISPLAY_PIECES;
         exsr BFC_STOP_DISPLAY_WEIGHT;
         exsr BFC_ITEM_DISPLAY_WEIGHT;
         exsr BFC_STOP_DISPLAY_CUSTOMER_NUMBER;
         exsr BFC_STOP_DISPLAY_CUSTOMER_NAME;
         exsr BFC_PALLET_FLAGS;
         exsr BFC_STOP_FLAGS;
         exsr BFC_ITEM_FLAGS;
         exsr BFC_USE_OMODSC;
700bA    exsr BFC_CUBE_MIN_HILITE;
700bA    exsr BFC_CUBE_MAX_HILITE;
700bA    exsr BFC_CUBE_HILITE_ZERO;
700bA    exsr BFC_ORIGINAL_OVERFLOW;
700bA    exsr BFC_AXLE_US;
700aD    //exsr BFC_USF_CUST;
700aD    //exsr BFC_CUSTOM_COLORS;
700cA    exsr BFC_AXLE_FRAME;
700cA    exsr BFC_AXLE_FRAME_HEIGHT;
700cA    exsr BFC_SUMMARY_FRAME_HEIGHT;
710aA    exsr BFC_MERGE_ITEM_DIFFERENT_ZONE;
750 A    exsr BFC_MERGE_ZONES_SINGLE_PALLET;

         if not full;
           exsr Append;
           largeStr += ']}';
         endif;

         // Extract section for call number

         startPos = ((pCallNum - 1) * outLen) + 1;
         endPos = pCallNum * outLen;
         if endPos > %len(largeStr);
           endPos = %len(largeStr);
         endif;
         len = endPos - startPos + 1;

         if len > 0;
           pJSON = %subst(largeStr: startPos: len);
         else;
           pJSON = '';
         endif;


         len = %len(largeStr);
         select;
           when len > 5000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: len-5000);
           when len > 4000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: len-4000);
           when len > 3000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: len-3000);
           when len > 2000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: len-2000);
           when len > 1000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: len-1000);
           when len > 0;
             debug1 = %subst(largeStr: 1: len);
         endsl;

       return;
      /end-free

     *----------------------------------------------------------------
     *  Append    Append to large string
     *----------------------------------------------------------------

      /free
       begsr Append;

         remainLen = maxLen - %len(largeStr) - 2;

         // If everything fits, append previous string

         if (%len(prvStr)+%len(currStr)) <= remainLen;
           largeStr += prvStr;
           prvStr = currStr;
           currStr = '';
           leavesr;
         endif;

         // Otherwise we have overflow condition.
         // We should at least be able to append the error string,
         // but try to include the previous string as well.
         // End result should be screen with the last field row
         // showing an Overflow message.

         full = *on;

         if (%len(prvStr)+%len(errStr)) > remainLen;
           largeStr += errStr;
         else;
           largeStr += prvStr + errStr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetOpt     Get options
     *----------------------------------------------------------------

      /free
       begsr GetOpt;

         chain(n) (opt) ddopts;

         if not %found(ddopts);
           val = '';
         else;
           val = %trimr(dovalue);
         endif;

       endsr;
      /end-free

700cA*----------------------------------------------------------------
700cA*  JsonNum      Add num option to JSON string
700cA*----------------------------------------------------------------
700cA
700cA /free
700cA  begsr JsonNum;

         currStr = delimiter
                 + '{"opt":"' + opt + '",'
750 A            +  '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"dsc":"' + dsc + '",'
                 +  '"min":"' + min + '",'
                 +  '"max":"' + max + '",'
                 +  '"val":"' + val + '"}';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonOnOff    Add OnOff option to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonOnOff;

         currStr = delimiter
                 + '{"opt":"' + opt + '",'
750 A            +  '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"dsc":"' + dsc + '",'
                 +  '"val":"' + val + '"}';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonSel1     Add first part of Select option to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonSel1;

         currStr = delimiter
                 + '{"opt":"' + opt + '",'
750 A            +  '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"dsc":"' + dsc + '",'
                 +  '"val":"' + val + '",';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonSel2     Add second part of Select option to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonSel2;

         currStr += delimiter2
                 +  '{"txt":"' + txt + '",'
750 A            +  '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +   '"val":"' + val + '"}';

         delimiter2 = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonComp1    Add first part of Compartment to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonComp1;

         currStr = delimiter
                 + '{"opt":"' + opt + '",'
750 A            +  '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"dsc":"' + dsc + '",';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonComp2    Add second part of Compartment to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonComp2;

         currStr += delimiter2
                 +  '{"cod":"' + cod + '",'
750 A            +   '"dsp":"' + dsp + '",'
750 A            +  '"dd2only":"' + dd2only + '",'
                 +   '"dsc":"' + dsc + '",'
                 +   '"clr":"' + clr + '"}';

         delimiter2 = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Option Routines for adding to JSON string
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  BFC_DD_TIPS
     *----------------------------------------------------------------

      /free
       begsr BFC_DD_TIPS;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_DD_TIPS';
         typ = 'onoff';
         dsc = 'Controls if the dropdown information boxes are '
             + 'displayed when the user stops the mouse over a '
             + 'Pallet, Stop, Tote or Item.';
         dsc = 'Include hover tips';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_DD_ITEM_SORT
     *----------------------------------------------------------------

      /free
       begsr BFC_DD_ITEM_SORT;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbmode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_DD_ITEM_SORT';
         typ = 'sel';
         dsc = 'Controls sort order of items under a stop.';
         dsc = 'Default sort order';

         exsr GetOpt;
         exsr JsonSel1;

         currStr += '"sel":[';
         delimiter2 = '';

         txt = 'Item';
         val = 'ITEM';
         exsr JsonSel2;

         txt = 'Slot';
         val = 'SLOT';
         exsr JsonSel2;

         txt = 'Cube';
         val = 'CUBE';
         exsr JsonSel2;

         txt = 'Weight';
         val = 'WEIGHT';
         exsr JsonSel2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_DD_TRUCK_PALLETS
     *----------------------------------------------------------------

      /free
       begsr BFC_DD_TRUCK_PALLETS;

         if full;
           leavesr;
         endif;

         opt = 'BFC_DD_TRUCK_PALLETS';
         typ = 'onoff';

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         dsc = 'Turns on the truck pallet graphic in the truck '
             + 'pallet frame. When off the Unload Sequence number '
             + 'of the pallet is displayed instead of the pallet '
             + 'graphic.';
         dsc = 'Display pallet icon (ON) or Unload Seq (OFF)';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_LOADING_SCREEN
     *----------------------------------------------------------------

      /free
       begsr BFC_LOADING_SCREEN;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_LOADING_SCREEN';
         typ = 'onoff';
         dsc = 'Controls whether the loading screen is displayed '
             + 'when entering dragdrop.';
         dsc = 'Display Loading';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_DD_REBUILD_ROUTE
     *----------------------------------------------------------------

      /free
       begsr BFC_DD_REBUILD_ROUTE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_DD_REBUILD_ROUTE';
         typ = 'onoff';
         dsc = 'Controls whether the Rebuild button is '
             + 'displayed.';
         dsc = 'Display Reload button';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_DD_PRINT_ROUTE
     *----------------------------------------------------------------

      /free
       begsr BFC_DD_PRINT_ROUTE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_DD_PRINT_ROUTE';
         typ = 'onoff';
         dsc = 'Controls whether the Print button is '
             + 'displayed.';
         dsc = 'Display Print button';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_EXPAND_ITEM_SPLITS
     *----------------------------------------------------------------

      /free
       begsr BFC_EXPAND_ITEM_SPLITS;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='N';
750 A    endif;

         opt = 'BFC_EXPAND_ITEM_SPLITS';
         typ = 'onoff';
         dsc = 'Controls if the item splits are expanded when '
             + 'the user enters dragdrop.';
         dsc = 'Expand splits upon start';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_MAX_CUBE_WARNING
     *----------------------------------------------------------------

      /free
       begsr BFC_MAX_CUBE_WARNING;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_MAX_CUBE_WARNING';
         typ = 'onoff';
         dsc = 'Controls if the Max Cube warning is displayed.';
         dsc = 'Display max cube warning when dropping';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_SPLIT_ITEM
     *----------------------------------------------------------------

      /free
       begsr BFC_SPLIT_ITEM;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_SPLIT_ITEM';
         typ = 'onoff';
         dsc = 'Controls if the right-click split items is allowed.';
         dsc = 'Allow partial drop with right-click drag';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_USE_OMODSC
     *----------------------------------------------------------------

      /free
       begsr BFC_USE_OMODSC;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_USE_OMODSC';
         typ = 'onoff';
         dsc = 'Controls if item description comes from OMODSC field.';
         dsc = 'Get item description from Item Misc file';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_USF_CUST
     *----------------------------------------------------------------

      /free
       begsr BFC_USF_CUST;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_USF_CUST';
         typ = 'onoff';
         dsc = 'Controls if we need to be jdk 1.4.2 for USF.';
         dsc = 'Use JDK 1.4.2 (deprecated)';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PALLET_DISPLAY_PIECES
     *----------------------------------------------------------------

      /free
       begsr BFC_PALLET_DISPLAY_PIECES;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_PALLET_DISPLAY_PIECES';
         typ = 'onoff';
         dsc = 'Controls if pieces are displayed at Pallet level.';
         dsc = 'Display pieces at Pallet level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_STOP_DISPLAY_PIECES
     *----------------------------------------------------------------

      /free
       begsr BFC_STOP_DISPLAY_PIECES;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_STOP_DISPLAY_PIECES';
         typ = 'onoff';
         dsc = 'Controls if pieces are displayed at Stop level.';
         dsc = 'Display pieces at Stop level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_STOP_DISPLAY_WEIGHT
     *----------------------------------------------------------------

      /free
       begsr BFC_STOP_DISPLAY_WEIGHT;

         if full;
           leavesr;
         endif;

750 A    dsp = 'Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_STOP_DISPLAY_WEIGHT';
         typ = 'onoff';
         dsc = 'Controls if weight is displayed at Stop level.';
         dsc = 'Display weight at Stop level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_STOP_DISPLAY_CUSTOMER_NUMBER
     *----------------------------------------------------------------

      /free
       begsr BFC_STOP_DISPLAY_CUSTOMER_NUMBER;

         if full;
           leavesr;
         endif;

750 A    dsp = 'Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_STOP_DISPLAY_CUSTOMER_NUMBER';
         typ = 'onoff';
         dsc = 'Controls if customer number is displayed '
             + 'at Stop level.';
         dsc = 'Display customer number at Stop level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_STOP_DISPLAY_CUSTOMER_NAME
     *----------------------------------------------------------------

      /free
       begsr BFC_STOP_DISPLAY_CUSTOMER_NAME;

         if full;
           leavesr;
         endif;

750 A    dsp = 'Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_STOP_DISPLAY_CUSTOMER_NAME';
         typ = 'onoff';
         dsc = 'Controls if customer name is displayed '
             + 'at Stop level.';
         dsc = 'Display customer name at Stop level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_ITEM_DISPLAY_PIECES
     *----------------------------------------------------------------

      /free
       begsr BFC_ITEM_DISPLAY_PIECES;

         if full;
           leavesr;
         endif;

750 A    dsp = 'Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_ITEM_DISPLAY_PIECES';
         typ = 'onoff';
         dsc = 'Controls if pieces are displayed at Item level.';
         dsc = 'Display pieces at Item level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_ITEM_DISPLAY_WEIGHT
     *----------------------------------------------------------------

      /free
       begsr BFC_ITEM_DISPLAY_WEIGHT;

         if full;
           leavesr;
         endif;

750 A    dsp = 'Y';
750 A    if tbMode = 'B';
750 A      dsp='B';
750 A      dd2only='Y';
750 A    endif;

         opt = 'BFC_ITEM_DISPLAY_WEIGHT';
         typ = 'onoff';
         dsc = 'Controls if weight is displayed at Item level.';
         dsc = 'Display weight at Item level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PALLET_FLAGS
     *----------------------------------------------------------------

      /free
       begsr BFC_PALLET_FLAGS;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_PALLET_FLAGS';
         typ = 'onoff';
         dsc = 'Controls if custom flags are displayed at Pallet level.';
         dsc = 'Display custom flags at Pallet level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_STOP_FLAGS
     *----------------------------------------------------------------

      /free
       begsr BFC_STOP_FLAGS;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_STOP_FLAGS';
         typ = 'onoff';
         dsc = 'Controls if custom flags are displayed at Stop level.';
         dsc = 'Display custom flags at Stop level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_ITEM_FLAGS
     *----------------------------------------------------------------

      /free
       begsr BFC_ITEM_FLAGS;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;
         opt = 'BFC_ITEM_FLAGS';
         typ = 'onoff';
         dsc = 'Controls if custom flags are displayed at Item level.';
         dsc = 'Display custom flags at Item level';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PRINT_COLOR
     *----------------------------------------------------------------

      /free
       begsr BFC_PRINT_COLOR;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;
         opt = 'BFC_PRINT_COLOR';
         typ = 'onoff';
         dsc = 'Controls if printing should default to color.';
         dsc = 'Default to color printing';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PRINT_BYPASS_DIALOG
     *----------------------------------------------------------------

      /free
       begsr BFC_PRINT_BYPASS_DIALOG;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_PRINT_BYPASS_DIALOG';
         typ = 'onoff';
         dsc = 'Controls if print dialog should by bypassed.';
         dsc = 'Bypass print dialog popup';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PRINT_AFTER_DONE
     *----------------------------------------------------------------

      /free
       begsr BFC_PRINT_AFTER_DONE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_PRINT_AFTER_DONE';
         typ = 'sel';
         dsc = 'Controls automatic printing when leaving DragDrop.';
         dsc = 'Automatically print when leaving';

         exsr GetOpt;
         exsr JsonSel1;

         currStr += '"sel":[';
         delimiter2 = '';

         txt = 'DragDrop';
         val = 'DD';
         exsr JsonSel2;

         txt = 'Dakota';
         val = 'DAKOTA';
         exsr JsonSel2;

         txt = 'Both';
         val = 'BOTH';
         exsr JsonSel2;

         txt = 'Off';
         val = 'OFF';
         exsr JsonSel2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PRINT_STYLE
     *----------------------------------------------------------------

      /free
       begsr BFC_PRINT_STYLE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_PRINT_STYLE';
         typ = 'sel';
         dsc = 'Controls part that is printed.';
         dsc = 'Default for print detail';

         exsr GetOpt;
         exsr JsonSel1;

         currStr += '"sel":[';
         delimiter2 = '';

         txt = 'All';
         val = 'ALL';
         exsr JsonSel2;

         txt = 'Truck';
         val = 'TRUCK';
         exsr JsonSel2;

         txt = 'Overflow';
         val = 'OVERFLOW';
         exsr JsonSel2;

         txt = 'Pallets';
         val = 'PALLETS';
         exsr JsonSel2;

         txt = 'Summary';
         val = 'SUMMARY';
         exsr JsonSel2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_PRINT_LAYOUT
     *----------------------------------------------------------------

      /free
       begsr BFC_PRINT_LAYOUT;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_PRINT_LAYOUT';
         typ = 'sel';
         dsc = 'Controls print layout.';
         dsc = 'Default for print layout';

         exsr GetOpt;
         exsr JsonSel1;

         currStr += '"sel":[';
         delimiter2 = '';

         txt = 'Portrait';
         val = 'PORTRAIT';
         exsr JsonSel2;

         txt = 'Landscape';
         val = 'LANDSCAPE';
         exsr JsonSel2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  BFC_CUSTOM_COLORS
     *----------------------------------------------------------------

      /free
       begsr BFC_CUSTOM_COLORS;

         if full;
           leavesr;
         endif;

         chain (pSessId) glosess;
         if not %found(glosess);
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_CUSTOM_COLORS';
         typ = 'comp';
         dsc = 'Defines compartment colors. Can also be defined '
             + 'through compartment maintenance.';
         dsc = 'Custom compartment colors';
         exsr JsonComp1;

         currStr += '"comp":[';
         delimiter2 = '';

         setll (gswhse) trkcomp;

         dow forever = forever;

           reade (gswhse) trkcomp;
           if %eof(trkcomp);
             leave;
           endif;

           cod = tpcode;
           dsc = %trimr(tpdesc);

           chain (tpwhse: tpcode) trkcompclr;
           if %found(trkcompclr);
             clr = %trimr(tpccolor);
           else;
             clr = '';
           endif;

           exsr JsonComp2;

         enddo;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  BFC_ORIGINAL_OVERFLOW
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr BFC_ORIGINAL_OVERFLOW;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_ORIGINAL_OVERFLOW';
         typ = 'onoff';
         dsc = 'Controls whether Overflow or Axles are displayed.';
         dsc = 'Display overflow summary';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  BFC_AXLE_US
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr BFC_AXLE_US;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_AXLE_US';
         typ = 'onoff';
         dsc = 'Controls display axle weights in U.S. or Metric.';
         dsc = 'Display axle weights in Lbs';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  BFC_CUBE_MAX_HILITE
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr BFC_CUBE_MAX_HILITE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_CUBE_MAX_HILITE';
         typ = 'onoff';
         dsc = 'Controls highlighting of overweight pallets.';
         dsc = 'Highlight overweight pallets';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  BFC_CUBE_MIN_HILITE
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr BFC_CUBE_MIN_HILITE;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_CUBE_MIN_HILITE';
         typ = 'onoff';
         dsc = 'Controls highlighting of underweight pallets.';
         dsc = 'Highlight underweight pallets';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  BFC_CUBE_HILITE_ZERO
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr BFC_CUBE_HILITE_ZERO;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_CUBE_HILITE_ZERO';
         typ = 'onoff';
         dsc = 'Controls highlighting of zero cube pallets.';
         dsc = 'Highlight zero cube pallets';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free

700cA*----------------------------------------------------------------
700cA*  BFC_AXLE_FRAME_HEIGHT
700cA*----------------------------------------------------------------
700cA
700cA /free
700cA  begsr BFC_AXLE_FRAME_HEIGHT;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_AXLE_FRAME_HEIGHT';
         typ = 'num';
         dsc = 'Sets the size of the axle frame.';
         dsc = 'Size of axle frame';

         exsr GetOpt;
         if val = '';
           val = '250';
         endif;

         min = '0';
         max = '999';

         exsr JsonNum;

         exsr Append;

       endsr;
      /end-free

700cA*----------------------------------------------------------------
700cA*  BFC_SUMMARY_FRAME_HEIGHT
700cA*----------------------------------------------------------------
700cA
700cA /free
700cA  begsr BFC_SUMMARY_FRAME_HEIGHT;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_SUMMARY_FRAME_HEIGHT';
         typ = 'num';
         dsc = 'Sets the size of the axle summary frame.';
         dsc = 'Size of axle summary frame';

         exsr GetOpt;
         if val = '';
           val = '410';
         endif;

         min = '0';
         max = '999';

         exsr JsonNum;

         exsr Append;

       endsr;
      /end-free

700cA*----------------------------------------------------------------
700cA*  BFC_AXLE_FRAME
700cA*----------------------------------------------------------------
700cA
700cA /free
700cA  begsr BFC_AXLE_FRAME;

         if full;
           leavesr;
         endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

         opt = 'BFC_AXLE_FRAME';
         typ = 'onoff';
         dsc = 'Controls displaying of axle frame.';
         dsc = 'Display axle frame';

         exsr GetOpt;
         exsr JsonOnOff;

         exsr Append;

       endsr;
      /end-free
710aA*----------------------------------------------------------------
710aA*  BFC_MERGE_ITEM_DIFFERENT_ZONE
710aA*----------------------------------------------------------------

710aA /free
710aA  begsr BFC_MERGE_ITEM_DIFFERENT_ZONE;

710aA    if full;
710aA      leavesr;
710aA    endif;

750 A    dsp='Y';
750 A    if tbMode = 'E';
750 A      dsp='N';
750 A    endif;

710aA    opt = 'BFC_MERGE_ITEM_DIFFERENT_ZONE';
710aA    typ = 'onoff';
710aA    dsc = 'Allows a Stop or Item that is on a pallet '
710aA        + 'consisting of only Merge records, to be dropped '
710aA        + 'on any pallet containing items, regardless of '
710aA        + 'Zone.';
710aA    dsc = 'Allow special merge-only drop';

710aA    exsr GetOpt;
710aA    exsr JsonOnOff;

710aA    exsr Append;

710aA  endsr;
710aA /end-free
740 A*----------------------------------------------------------------
740 A*  BFC_DISPLAY_LOCATION_PIECES
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr BFC_LOCATION_DISPLAY_PIECES;
740 A
740 A    if full;
740 A      leavesr;
740 A    endif;
740 A
750 A    dsp='N';
750 A    if tbMode = 'E' or tbMode='B';
750 A      dsp='Y';
750 A      if tbMode='B';
750 A        dsp='O';
750 A        dd2only='Y';
750 A      endif;
750 A    endif;

740 A    opt = 'BFC_LOCATION_DISPLAY_PIECES';
740 A    typ = 'onoff';
740 A    dsc = 'Display pieces at Location level';
740 A
740 A    exsr GetOpt;
740 A    exsr JsonOnOff;
740 A
740 A    exsr Append;
740 A
740 A  endsr;
740 A /end-free
740aA*----------------------------------------------------------------
740aA*  BFC_DISPLAY_PRINTER
740aA*----------------------------------------------------------------
740aA
740aA /free
740aA  begsr BFC_DISPLAY_PRINTER;
740aA
740aA    if full;
740aA      leavesr;
740aA    endif;
740aA
750 A    dsp='Y';
750 A    if tbMode='B';
750 A      dsp='B';
750 A    endif;
750 A
740aA    opt = 'BFC_DISPLAY_PRINTER';
740aA    typ = 'onoff';
740aA    dsc = 'Display Printer Flag checkbox in Built Routes';
740aA
740aA    exsr GetOpt;
740aA    exsr JsonOnOff;
740aA
740aA    exsr Append;
740aA
740aA  endsr;
740aA /end-free
750 A*----------------------------------------------------------------
750 A*  BFC_MERGE_ZONES_SINGLE_PALLET
750 A*----------------------------------------------------------------
750 A
750 A /free
750 A  begsr BFC_MERGE_ZONES_SINGLE_PALLET;
750 A
750 A    if full;
750 A      leavesr;
750 A    endif;
750 A
750 A    dsp='N';
750 A    if tbmode = 'E' or tbMode='B';
750 A      dsp='Y';
750 A      if tbMode='B';
750 A        dsp='O';
750 A        dd2only='Y';
750 A      endif;
750 A    endif;
750 A
750 A    opt = 'BFC_MERGE_ZONES_SINGLE_PALLET';
750 A    typ = 'sel';
750 A    dsc = 'Merge unlike zones into a single pallet';
750 A
750 A    exsr GetOpt;
750 A    exsr JsonSel1;
750 A
750 A    currStr += '"sel":[';
750 A    delimiter2 = '';
750 A
750 A    txt = 'Not Allowed';
750 A    val = 'N';
750 A    exsr JsonSel2;
750 A
750 A    txt = 'Keep separate by default';
750 A    val = 'S';
750 A    exsr JsonSel2;
750 A
750 A    txt = 'Merge by default';
750 A    val = 'M';
750 A    exsr JsonSel2;
750 A
750 A    currStr += ']}';
750 A
750 A    exsr Append;
750 A
750 A  endsr;
750 A /end-free
