710 AHdftactgrp( *NO )
     H  actgrp( *NEW )
     Hbnddir( 'QC2LE' )
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PCOMPWO - Production Component/WO Validation
     *  26 December  2018
     *  Mike Rooker
     *
     *    -PARMS
     *       pWhse = Warehouse
     *       pComponent = Component
     *       pRmItem   = Raw Material Item
     *       pcmd      = Command value
     *       arr       = Component Array
     *       arr2      = Component Recursive Check Array
     *       pCntr1    = Component Array  Counter
     *       pCntr2    = Component Recursive Array  Counter
     *       pLevel    = Program level in Recursive process
     *       pRtnMsg   = Error message for Recursive Level
     *
     *    -CMD Codes - BA = BOM Add
     *                 BD = BOM Delete
     *                 BI = BOM Inquiry
     *                 BR = BOM Rebuild
     *                 WI = Work Order Inquiry
     *                 WB = Work Order Inquiry (Fin good and comp)
     *                 WR = Work Order Inquiry (Raw Mat and comp)
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*  12/26/18  MR   7.20
     *    - Created.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     *
     d message         s            100
     d whse            s              3
     d component       s            100
     d rmitem          s             15
     d orgComponent    s            100
     d orgRmItem       s             15
     d orgCmd          s              2
     d cmd             s              2
     d arr             s             15    dim(100)
     d arr2            s             15    dim(100)
     d arr3            s             15    dim(100)
     d arr3w           s             15    dim(500)
     d arr3c           s            500    dim(100)
     d acntr           s              3    inz('000')
     d acntr2          s              3    inz('000')
     d cntr            s              3S 0
     d lvlcntr         s              3    inz('000')
     d forever         s               n
     d fingood         s            100
     d fingood2        s          65000
     d wfingood        s            100
     d sqlstmt         s           5000
     d length          s              3s 0
      *
     *----------------------------------------------------------------
     *  Procecdural Call
     *----------------------------------------------------------------
     *
     d pCompontWo      PR           100
     d      whse                      3
     d      component               100
     d      rmitem                   15
     d      cmd                       2
     d      arr                      15    dim(100)
     d      arr2                     15    dim(100)
     d      arr3w                    15    dim(500)
     d      arr3c                   500    dim(100)
     d      pcntr                     3
     d      pcntr2                    3
     d      pLevel                    3
     d      pRtnMsg                 100
      *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    whse
     c                   parm                    cmd
     c                   parm                    component
     c                   parm                    rmItem
     c                   parm                    message
     c                   parm                    arr3w
     c                   parm                    arr3c
      //
      /free
          if cmd <> 'BA'
             and cmd <> 'BD'
             and cmd <> 'BI'
             and cmd <> 'BR'
             and cmd <> 'WI'
             and cmd <> 'WB';
          eval message = *blanks;
          message = '*ERROR - Invalid Command';
          endif;
          select;
          when cmd = 'BA'
               or cmd = 'BD'
               or cmd = 'BI'
               or cmd = 'BR';
            exsr doBomVal;
          when cmd = 'WI';
            exsr doWoInquiry;
          when cmd = 'WB'
               or cmd = 'WR';
            exsr doWoInquiryFCR;
          endsl;
          *inlr = *on;
       //***********************************
       //   Bill of Material Check
       //***********************************
        begsr doBOMVal;
        orgComponent = component;
        orgRmItem = rmItem;
        orgCmd  =  cmd;
        if cmd = 'BI';
           exec sql insert into pbom values(:whse,:component, 9999, :RmItem,
               0,0,0,0,0,'X','X','X', 19500101, 19500101, 'N');
        endif;
        message = pcompontwo(WHSE:COMPONENT:
                         RMITEM:CMD:ARR:arr2:arr3w:arr3c:
                         acntr:acntr2:lvlcntr:message);

        // If no recusive error, check everything containing
        // the component

720aA   if %subst(message:1:6) <> '*ERROR';
            fingood2 = ''''+%trim(component)+'''';
            arr3 = *blanks;
            cntr = 0;
            //
            //Get all component/finished good containing the component
            //  passed in
            //
            forever = *on;
            dow forever = *on;
            sqlstmt = 'select bmfgi from pbom join itemprd on bmfgi = '+
                    'ipitem where bmrmi in ('+%trim(finGood2)+')';
            //
            finGood2 = *blanks;
            exec sql Declare cursor2 scroll cursor for mainStmt;
            exec sql Prepare mainStmt from :Sqlstmt;
            exec sql Open cursor2;
            dow sqlcod <> 100;
               exec sql fetch next from cursor2 into :wFinGood;
               if sqlcod=100;
                 leave;
               endif;
               fingood2 = %trim(finGood2)+''''+ %trim(wFinGood)+''''+',';
               cntr = cntr + 1;
               arr3(cntr) = wfingood;
            enddo;
            exec sql close cursor2;
            length = %len(%trim(finGood2));
            if length = 0;
               leave;
            endif;
            finGood2 = %subst(%trim(finGood2):1:length-1);
            enddo;
          //
          // Walk through remaining components/finished goods
          // and validate
          //
          cntr = 0;
          dou cntr = 100;
            cntr = cntr + 1;
            if arr3(cntr) = *blanks;
               leave;
            endif;
            component = arr3(cntr);
            if cntr = 100;
               leave;
            endif;
            //
            // Reset Parmeters
            exsr resetParms;
            //
            cmd = 'BD';
            message = pcompontwo(whse:component:rmitem:cmd:arr:arr2:
               arr3w:arr3c:acntr:acntr2:lvlcntr:message);
            //
720aA       if %subst(message:1:6) = '*ERROR';
               leave;
            endif;
          enddo;
          //
        endif;
          //**********************************************************
          //Send Array of Components back to create link parms for MRC
          if cmd = 'BI';
             arr3w = arr;
          endif;
          //**********************************************************
          //
          exec sql delete from pbom where bmeffd = 19500101;
          component = orgComponent;
          rmItem = orgRmitem;
          cmd = orgCmd;
        endsr;
          //
       //***********************************
       //   Work Order Inquiry
       //***********************************
        begsr doWoInquiry;
            exsr resetParms;
            message = pcompontwo(whse:component:rmitem:cmd:arr:arr2:
               arr3w:arr3c:acntr:acntr2:lvlcntr:message);
        endsr;
       //***********************************
       //   Work Order Inquiry
       //***********************************
        begsr doWoInquiryFCR;
            exsr resetParms;
            message = pcompontwo(whse:component:rmitem:cmd:arr:arr2:
               arr3w:arr3c:acntr:acntr2:lvlcntr:message);
        endsr;
        //
        //*** Reset Parms for procedure call
        //
        begsr resetParms;
            arr = *blanks;  // main array
            arr2 = *blanks; // component array
            arr3w = *blanks; // workOrder array
            arr3c = *blanks; // components in workorder array
            acntr = '000';  // main array counter
            acntr2 = '000'; // component array coutner
            lvlcntr = '000';  // level counter
        endsr;
      /end-free
      *
      /copy qcopysrc,pCompontWo
