      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*yes)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT120A    Create Production Replenishments
     *  18 August 2014
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  08/18/14  KDE  6.50
     *    - Created.
     *
650 A*  10/05/14  KDE  6.50a
     *    - Add code to support a Production Quantity Breakdown
     *
650 A*  12/17/14  KDE  6.50b
     *    - Add code to support a Work Order System
     *
710 A*  02/02/17  KDE  7.10
     *    - Recompile due to file change in Itemprd
     *
710 B*  11/29/17  MR   7.10b
     *    - Add code for *MINMAX functionality
     *
720 A*  01/22/18  KDE  7.20
     *    - Add code to auto generate WIP Work Orders for specific items as required
     *      per the BOM
     *
730 A*  02/01/19  KDE  7.30
     *    - Physically remove mod 720 A for readability purposes since it was never
     *      used anywhere and we have a newer and better method to handle component
     *      items.  This mod also includes the newer code to handle components
     *
     *----------------------------------------------------------------
     *  Basic Information
     *
     *  This program removes all Work Orders flagged as Suggestions
     *  where WOSTAT = "S".  Any other status in WOSTAT will remain
     *  meaning the Work Order is either working or plans are in the
     *  making for it to be working. When the Batch process runs
     *  (LT120CL) this program will process with the selected option
     *  (AVGPRD or PRDQTY) and then *RMAVLF to set the raw material
     *  availability since all suggestions must be processed before
     *  we can determine if enought raw materials exist to do all
     *  Work Orders.
     *
     *  This process calls DRIPRTYRPL to use Replenishment logic
     *  for the production item in question.  DRIPRTYRPL then
     *  returns what it would normally replenishment and a Work
     *  Order is generated for that quantity.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     Fpiritem   if   e           k disk
     fpwrkord   uf   e           k disk
     flt120apr  o    e             printer oflind(*in90)
     F                                     usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D wrPrc           s             15    dim(100)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#DRIPARMS
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D aWhse           s              3
     d dmdType         s                   like(prplb)
     d rm_replen       s               n
640bAD forever         s               n
     d hmsmdy          s             12  0 inz
     d pSessId         s             40    varying
     d pUser           s             10    varying
     d pPgm            s             20    varying
     D pButchMsg       s            500    varying
650aAD pMessage        s             99    varying
     D pPackMsg        s            500    varying
     D pShipMsg        s            500    varying
     D pWhse           s              3p 0
     d pWo#            s             13    varying
     D prplb           s              8
     D pMsg            s             60
     D pRsug           s              1
     D pReturn         s              8
     d rdate           s              6  0 inz
     d rtime           s              6  0 inz
     D saveVer#        s                   like($ppver#)
     D sq              c                   Const('''')
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     d datetime        s             14
     d wkError         s               n
     d wkRerr2         s             50
     d woCount         s              5  0

    *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D iprecsql      E Ds                  Extname(ItemPrd)
     D prrecsql      E Ds                  Extname(pReplen)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Station ID
     *
     *    Returned Parameters
     *      -None -
     *
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *
     *----------------------------------------------------------------     ****
     C     *entry        plist
     C                   parm                    pRplb
     C                   parm                    aWhse
     c                   parm                    preturn
     c                   parm                    pMsg
     c                   parm                    pRsug
     c                   exsr      init

      /free

         // Perform requested Work Order Type
         Monitor;
           pWhse = %dec(aWhse:3:0);
         on-error 105;
         Endmon;

         if pRsug = 'Y';      // Remove unmodified Suggestions
            exsr delSuggestions;
         endif;

         select;
            when pRplb = '*PRDQTY';     // Imported Production from Customer
               dmdType = '*PRDQTY';
               exsr DMDPRC;
            when pRplb = '*AVGPRD';     // Average Sales for Item
               dmdType = '*AVGPRD';
               exsr DMDPRC;
710bA       when pRplb = '*MINMAX';     // Min/Max
710bA          dmdType = '*MINMAX';
710bA          exsr DMDPRC;
         endsl;

         if pMsg = ' ';
            pMsg = 'Process completed normally';
         endif;

         write total;
         close lt120apr;

         *inlr = *on;

      /end-free

    * -------------------------------------------------------------------
    **  Initialize everything
    *--------------------------------------------------------------------

     c     Init          begsr
     c                   eval      *in90 = *off
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     c                   OPEN      LT120APR
     c                   write     header
650nA*
650nA*  Define a unique Session for Production routines
650nA*
650nAc                   eval      pSessId = %trim('LT120A' +
650nAc                             %char(%date():*iso0) +
650nAc                             %char(%time():*hms0))
     c                   endsr
      /free
      //---------------------------------------------------------
      // delSuggestions - This routie will review Suggestions
      //     every time it is ran to determine whether any should
       //     be purged.  If the Work Order is in a Suggestion
       //     Status it means the system generated this based on
       //     demand and availability but no one has moved forward
       //     to planning at this point.  Therefore, any WO at Suggestion
       //     status can be deleted, but nothing else
      //---------------------------------------------------------

          begsr delSuggestions;

             // setup date to use for comparison when purging suggestions
             if %char(%time():*hms0) > '030000';
                datetime = %char(%date():*iso0) + %editc(030000:'X');
             else;
                datetime = %char(%date - %days(1):*iso0) +
                              %editc(030000:'X');
             endif;

             // loop through Work Order file looking for records to purge
             setll (pWhse) pWrkOrd;
             reade (pWhse) pWrkOrd;
             dow not %eof(pWrkOrd);
                // purge any Planned orders that were originated by
                // Suggestion process and the Make quantity is equal
                // to the Need quantity.
                if woorig = 'S' and wostat = 'S';
                   delete worec;
                   // delete raw material requirements associated with
                   // that Work Order/Finished Good
                   exec sql Delete from pWrkOrdr
                     where wrwhse = :wowhse and wrwo# = :wowo#;
                else;
                   unlock pWrkOrd;
                endif;
                reade (pWhse) pWrkOrd;
             enddo;
          endsr;

      //---------------------------------------------------------
      // FgSugg -   Call command *CRTSUGG in DRIPROD.  This command
      //            first calls DRIPRTYRPL to determine demand and
       //            how much of that demand is needed in production.
       //            It returns that value to DRIPROD - routine
       //            CRTSUGG which then reduces again based on any
       //            any stock found in PAR slots and finally creates
       //            a new Work Order with any remaining need
      //---------------------------------------------------------

          begsr fgSugg;

                savever# = $ppver#;
                clear $pprod;
                clear $pprod2;
                $ppver# = savever#;

                $ppSessIdu = *on;
                $ppSessid  = pSessId;
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $ppitemu = *on;
710bA           if prplb = '*MINMAX';
710bA              $drisubcmd = '*MINMAX';
710bA              $ppwhse  = ipwhse;
710bA              $ppitem  = ipitem;
710bA              $prqtyn = 0;
710bA              $ppneed = 0;
710bA           else;
                if prplb = '*AVGPRD';
                   chain (ipwhse:ipitem) piritem;
                  // call DRIPRTYRPL to get Average Sales Demand Qty
                   eval savever# = $prver#;
                   clear $prtyrpl;
                   eval $prver# = savever#;
                   $prqtyn = 0;
                   $prwhse  = ipwhse;
                   $pritem  = ipitem;
                   $dricommand = '*PRTYRPL';  // cal getqtyneeded in DRIPRTY
                   $drisubcmd = '*AVGPRD';
                   $drisys2upd = 'D';
                   exsr zzDriCop;
                   $ppwhse  = ipwhse;
                   $ppitem  = ipitem;
                   $ppneed = $prqtyn; // Send Average sales num.to DRIPROD
                else;
                   chain (prwhse:pritem) piritem;
                   $ppitem  = pritem;  // Customer Supplied Demand
                   $ppdest = 'P';
                   $ppdestu = *on;
730aA              $drisubcmd = '%CHKFORWO';
730aA              $dricommand = '*PROD';
730aA              $drisys2upd = 'D';
730aA              exsr zzDriCop;
730aA              if $ppWo#='*NF';
730aA                 $ppWo#=*blanks;
730aA              endif;
                   $drisubcmd = '%PRDQTY';
                   $ppneed = prqty;
                endif;
710bA           endif;
                $ppuser = #User;
                $ppuseru = *on;
                $ppdest = 'P';
                $ppdestu = *on;
                $ppcust = 0;
                $ppcustu = *on;
                $ppcustwo = ' ';
                $ppcustwou = *on;
                $ppcord = 0;
                $ppcordu = *off;
                $pplneno = 0;
                $pplnenou = *on;
730aD           //$ppWo# = ' ';
730aD           //$ppWo#u = *on;
730aA           $ppWipa = 'A';
730aA           $ppWipau = *on;
                $dricommand = '*PROD';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
                   pMessage = $driMessage;
                endif;

          endsr;

        // *************************************************************
        // Create Production replenishments from Average Sales of Prod Item
        // *************************************************************

         begsr dmdprc;

            // Loop through production flagged items looking for needed
            // Suggestions

            // Generate SQL that returns all items marked as Finished
            // goods
            sqlStmt = 'Select * from itemprd ' +
                 'where ipprdflg = ' + sq + 'F' + sq +
730 A            ' or ipprdflg=' + sq + 'C' + sq +
                 ' order by ipmfgno';

            exec sql PREPARE sela FROM :SqlStmt;
            exec sql DECLARE itemprda SCROLL CURSOR FOR SELA;
            exec sql OPEN Itemprda;

            exec sql fetch first from itemprda into :iprecsql;

            dow Sqlstt = sqlSuccess;

              // determine if any active Work Order exist for this item
              exec sql
                select count(*)
                 into :woCount
                 from pwrkord
                 where wowhse = :pwhse and woitem = :ipitem
730aD                  //and (wostat ='S' or wostat = 'P' or
730aD                  //wostat = 'R' or wostat = 'W');
730aA                  and wostat ='S';

              // if open Work Orders exist DO NOT generate additional
              // Work Order
              if woCount = 0;
                 // if using Customer Demand File see if this item
                 // exist
                 if dmdtype = '*PRDQTY';
                    clear prrecsql;
                    exec sql
                      select *
                        into :prrecsql
                        from pReplen
                         where prwhse = :pwhse and pritem = :ipitem and
                               prstat<>'P';
                 endif;
                 if (dmdType = '*PRDQTY' and pritem = ipitem)
710bM               or dmdtype = '*AVGPRD'
710bA               or dmdtype = '*MINMAX';
                    exsr fgsugg;
                    prqty = $ppmake;
                    exsr detailline;
                 endif;
              endif;

              if dmdType = '*PRDQTY' and pritem = ipitem;
                 exec sql
                   update pReplen
                    set prstat = 'P'
                    where prwhse = :ipwhse and pritem=:ipitem;
              endif;

              exec sql fetch next from itemprda into :iprecsql;

           enddo;

           // Close SQL cursor, end program
           Exec Sql Close Itemprda;

         endsr;

      /end-free

     *----------------------------------------------------------------
     *  zzDriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      pMsg      = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
     c                   endsl

     c                   endsr

     * -------------------------------------------------------------------
     **  Print Error Detail line
     *--------------------------------------------------------------------

     c     detailline    begsr
      /free
          // if overflow on print headings
          if *in90 = *on;
             write header;
             *in90 = *off;
          endif;

          if %trim($drireturn) <> '*OK';
             pMsg = %trim($drireturn) + ' - ' + %trim(pMessage);
          else;
             pMsg = 'Suggestion: ' + $ppwo# + ' generated for ' +
                     %char($ppMake) + ' pieces';
          endif;
          if pMsg <> ' ' and pMsg <>'No overflow available';
             wktote =wktote + 1;
             write detail;
          endif;

      /end-free
     c                   endsr
     *
     *  COMPILE TIME TABLES
     *
