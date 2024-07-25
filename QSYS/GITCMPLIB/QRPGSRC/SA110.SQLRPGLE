     h option(*nodebugio)
     h dftactgrp(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  SA110      Special Aisle Code Maintenance
     *  16 February 2009
     *  Chuck Manny
     *
     *  Revisions:
     *
     *  Created: 02/16/2009 cwm
     *
     *----------------------------------------------------------------
     *
     *  Indicator Usage
     *
     * Indicator  Description
     * ---------  -----------
     * F3   03    Exit Program
     * F5   05    Refresh Entry Screen
     * F6   06    Add New Record
     * F12  12    Return To Previous Screen
     *
     *----------------------------------------------------------------
     *
     *  Prefix Usage
     *
     *  Prefix  Description
     *  ------  -----------
     *  CN      Constants
     *  DS      Data Structure Defined
     *  EX      External Data Structure
     *  FM      Display File Field Name
     *  GW      General Work Fields Program Defined
     *  HL      Hold/Save Work Area
     *  PD      Procedure Defined Work Field
     *  PR      Procedure Name
     *  PX      Import / Export Procedure Name
     *  SF      Subfile Field Names
     *  WK      Standard Program Defined Work Field
     *  EX      External Data Structure Definition
     *
     *  #P      Program Info Data Structure Fields
     *
     *----------------------------------------------------------------
     *
     *  FS-WMS File Specs
     *
     fsa110fm   cf   e             WorkStn Sfile(aisp01S1:rrn)
     fspclaisl  uf a e           k disk
     *
     *----------------------------------------------------------------
     *
     * Sub Procedure Prototypes
     *
     d prAddRecord     pr
     *
     d prClearSfl      pr
     *
     d prDltRecord     pr
     *
     d prDsplaySfl     pr
     *
     d prLoadSfl       pr
     *
     d prPosition      pr
     *
     d prPrcSelect     pr
     *
     d prRstWindow     pr
     *
     d prSetWindow     pr
     *
     d prUpdRecord     pr
     *
     d prUpdWindow     pr
     *
     d prValidate      pr
     *
     *----------------------------------------------------------------
     *  External Data Structure
     *

     *
     * Original File
     d exspclaisl    e ds                  extname(spclaisl)
     *
     * Subfile
     d exspcSfl      e ds                  extname(spclaisl)
     d                                     prefix(sf)
     *
     * Maintenance
     d exspcEnter    e ds                  extname(spclaisl)
     d                                     prefix(fm)
     *
     * Hold/Save
     d exspcHld      e ds                  extname(spclaisl)
     d                                     prefix(hl)
     *
     * Delete
     d exspcDlt      e ds                  extname(spclaisl)
     d                                     prefix(dl)
     *
     *----------------------------------------------------------------
     *  Table and Array Definitions
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Re-mapped file fields.
     *
     *----------------------------------------------------------------
     * Called program parameters
     *
     *----------------------------------------------------------------
     * Program Info Data Structure
     *
     d                sds
     d  #pProg           *proc
     d  #pJob                244    253
     d  #pUser               254    263
     d  #pJobn               264    269
     d  #pJobdt              276    281  0
     d  #pJobtm              282    287  0
     *
     *----------------------------------------------------------------
     *  Constants
     *
     d cnTwo           c                   ' 2'
     d cnFive          c                   ' 5'
     d cnFour          c                   ' 4'
     d cnErrorOne      c                   'Invalid Aisle Entry'
     d cnErrorTwo      c                   'Invalid Description Entry'
     d cnErrorThr      c                   'Record Allready Exists   '
     *----------------------------------------------------------------
     *  Internaly Defined Work Fields
     *
     d wkSaaisl        s              3    inz
     d gwSaaisl        s              3    inz
     d wksaais1        s              3
     d wksadesc1       s             30
     d wkx             s              2  0 inz
     *
     *----------------------------------------------------------------
     *  Data Structures
     *
     d dsX0101         ds             6
     d  dsX123                 1      3
     d  dsX456                 4      6
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $xxxxx  xxxxxxx xx xxxxxxx.
     *
     *    Returned Parameters
     *      xxxxx   xxxx xx xxxx
     *
     *----------------------------------------------------------------
     ** Main line
     *----------------------------------------------------------------
     *
     * Position To Record
     *
      /free

        dow *inkc = *off;

          if xxSaaisl <> wkSaaisl;
            callp prClearSfl();
            callp prPosition();
            callp prLoadSfl();
          endIf;

          // Display Existing Records

          if *in25 = *off;
            prDsPlaySfl();
          else;

            // Roll
            *in25 = *off;
            prLoadSfl();
            prDsplaySfl();
          endIf;

          // Display Help Text
          if *inka = *on;
            exfmt aisp01h1;
            *in01 = *off;
          endIf;

          // Exit Pgm
          if  *inkc = *on;
            leave;
          endIf;

          if *inkc = *off
           and rrn <> 0;
             prPrcSelect();
          endIf;

          // Add Record
          if *inkf = *on;
            prAddRecord();

            if *inkc = *on;
              leave;
            endIf;

            *inkl = *off;
            *inkf = *off;
          endIf;

        endDo;

        // EOP

        *inlr = *on;

       /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
      /free
       begsr  *INZSR;

         // exec sql
         //  Declare AisleCode cursor for select * from spclaisl;

         xxSaaisl = *loval;
         prClearSfl();
         prPosition();
         prLoadSfl();

       endSr;

      /end-free
     *
     *----------------------------------------------------------------
     *
     * prAddRecord - Add New Record
     *
     p prAddRecord     b
     d  prAddRecord    pi
     *
     d  pcCrtAsl       c                   'Create Aisle'
     *
      /free
         prRstWindow();
         dou  *inkl = *on or *inkc = *on;

           *inkf = *off;
           @Action = pcCrtAsl;

           exfmt  aisp01r1;

           if  *inkl = *on;
             iter;
           endIf;

           if  *inkc = *on;
             leave;
           endIf;

           *in66 = *off;
           @msg1 = *blanks;

           prValidate();

           if @msg1 = *blank;

             // Execute Select To Verify Record Does Not Exist

             exec sql
               select saaisl, sadesc into :wksaaisl, :wksadesc1
               from spclaisl
               where saaisl = :fmsaaisl;

             // Record Not Found

             if  sqlcod  =  100;
               exSpclAisl  =  exSpcEnter;
               write  sarec;
               prRstWindow();
               *inkl = *on;
             else;
               @msg1 = cnErrorThr;
               exspcHld = *blanks;
             endif;

           endif;

           if  @msg1 <> *blank;
             *in66 = *on;
           endif;

         endDo;

         *in66 = *off;

         @msg1 = *blanks;
         xxSaaisl = *loval;

         return;

      /end-free

     p prAddRecord     e
     *
     *----------------------------------------------------------------
     *
     * prClearSfl - Clear/Reset Subfile
     *
     p prClearSfl      b
     d  prClearSfl     pi
     *
      /free

         *in33 = *on;

         write  aisp01c1;
         *in33 = *off;
         rrn = *zeros;

         write  aisp01r2;

         *in32 = *on;

         return;

      /end-free
     *
     p prClearSfl      e
     *
     *----------------------------------------------------------------
     *
     * prUpdRecord - Update File w/New Record
     *
     p prDltRecord     b
     d  prDltRecord    pi
     *
      /free

         dou  *inkl = *on;
           exSpcDlt = exSpcSfl;
           dlOpt = sfOpt1;

           // Display Delete
           exfmt  aisp01r3;

           // F12 Return
           if  *inkl = *on;
             iter;
           endif;

           // Delete Selected Record
           exec sql
             delete from spclAisl where saaisl = :dlsaaisl;
           leave;
         enddo;

         eval xxSaaisl = *loval;

         Return;

      /end-free
     *
     p prDltRecord     e
     *
     *----------------------------------------------------------------
     *
     * prDsplaySfl - Display Records
     *
     p prDsplaySfl     b
     d  prDsplaySfl    pi
     *
      /free

         if rrn <> 0;
           *in31 = *on;
         endIf;

         xxSaaisl = *blanks;
         wkSaaisl = *blanks;

         write aisp01r2;
         exfmt aisp01C1;

         Return;

      /end-free
     *
     p prDsplaySfl     e
     *
     *----------------------------------------------------------------
     *
     * prLoadSfl  - Load List Display/Subfile
     *
     p prLoadSfl       b
     d  prLoadSfl      pi
     *

      /free

         for wkx = 1 to 10;
           read  spclAisl;

           if  %eof(spclAisl);
             leave;
           endIf;

           rrn = rrn + 1;
           exspcsfl = exspclaisl;
           gwSaaisl = saaisl;

           write  aisp01s1;
         endFor;

         Return;

      /end-free
     *
     p prLoadSfl       e
     *
     *----------------------------------------------------------------
     *
     * prPosition - Position To Record In File
     *
     p prPosition      b
     d  prPosition     pi
     *
      /free
         wkSaaisl = xxSaaisl;

         setll (wkSaaisl) spclaisl;
         if not %found(spclaisl);
           wkSaaisl = *blanks;
           setll (wkSaaisl) spclaisl;
         endIf;
         return;
      /end-free
     *
     p prPosition      e
     *
     *----------------------------------------------------------------
     *
     * prPrcSelect - Read and Process Next Selected Record in Subfile.
     *
     p prPrcSelect     b
     d  prPrcSelect    pi
     *
      /free

         readc  aisp01S1;
         dow %eof = *off;

           select;

             when sfOpt1 = cnTwo;
               prUpdRecord();

             when sfOpt1 = cnFour;
               prDltRecord();

             when sfOpt1 = cnFive;
               prUpdRecord();

           endsl;

           *in12 = *off;
           *in73 = *off;

           sfOpt1 = *blank;
           update  aisp01S1;
           readc  aisp01S1;

         endDo;

         return;

      /end-free
     *
     p prPrcSelect     e
     *
     *----------------------------------------------------------------
     *
     * prRstWindow - Reset Maintenance Screen
     *
     p prRstWindow     b
     d  prRstWindow    pi
     *
      /free

         clear  aisp01r1;
         *in66 = *off;
         Return;

      /end-free
     *
     p prRstWindow     e
     *
     *----------------------------------------------------------------
     *
     * prUpdRecord - Update File w/New Record
     *
     p prUpdRecord     b
     d  prUpdRecord    pi
     *
     d  pcUpdAsl       c                   'Update Aisle'
     d  pcCrtAsl       c                   'Create Aisle'
     d  pcAisVw        c                   ' View Aisle '
     *
      /free

         prRstWindow();

         dou *inkl = *on;
           *in05 = *off;
           *in62 = *on;

           select;

             when  sfOpt1 = cnFive;
               @action = pcAisVw;
               *in73 = *on;

             when  sfOpt1 = cnTwo;
               @action = pcUpdAsl;

             other;

               @action = pcCrtAsl;

           endSl;

           exspcenter = exspcsfl;

           // Display Maint
           exfmt  aisp01r1;

           // F12 Return
           if  *inkl = *on;
             iter;
           endif;

           @Msg1 = *blanks;
           *in66 = *off;

           // Change Selected Record
           if sfOpt1 = cnTwo;

             prValidate();

             if @msg1 = *blanks and *inkl = *off
                                and *inkc = *off;

               // Execute Select To Verify Record Exist's
               exec  sql
                 select saaisl, sadesc into :wksaaisl, :wksadesc1
                 from spclaisl
                 where saaisl = :fmsaaisl;

               // Record Found, Update Record
               if  sqlcod  =  000;
                 exec sql
                   update  spclaisl Set sadesc = :fmsadesc
                   where saaisl = :fmsaaisl;
                 prRstWindow();
                 *inkl = *on;
               endif;

             endIf;

           endIf;

           // End - Change Selected Record
           if  *inkl = *on;
             iter;
           endif;

         endDo;

         @msg1 = *blanks;
         xxsaaisl = *loval;

         Return;

      /end-free
     *
     p prUpdRecord     e
     *
     *------------ ---------------------------------------------------
     *
     * prValidate - Error Checking.
     *
     p prValidate      b
     d  prValidate     pi
     *
      /free

         select;

           when  fmSaaisl = *blanks;
             *in66 = *on;
             *in11 = *on;
             *in21 = *on;
             @msg1 = cnErrorOne;

           when  fmSaDesc = *blanks;
             *in66 = *on;
             *in12 = *on;
             *in22 = *on;
             @msg1 =  cnErrorTwo;

         endSl;

         Return;

      /end-free
     *
     p prValidate      e
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C*    zmcmsg        begsr
     C*                  eval      *in97 = *off
     C*                  write     msgctl
     C*                  eval      msgk = *zeros
     C*                  write     msgclr
     C*                  move      '*CLEAR '     #msgid
     C*                  move      '*NULL  '     #msgtp
     C*                  exsr      zmpmsg
     C*                  endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C*    zmdmsg        begsr
     C*                  eval      *in97 = *on
     C*                  if        msgk > 0
     C*                  write     msgctl
     C*                  eval      msgk = *zeros
     C*                  endif
     C*                  endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C*    zmimsg        begsr
     C*                  eval      #pgmq = #pgm
     C*                  exsr      zmcmsg
     C*                  endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C*    zmpmsg        begsr
     C*                  if        $msgf = *blanks
     C*                  eval      $msgf = #msgf
     C*                  endif
     C*                  call      'PUTMSG'
     C*                  parm                    $msgf
     C*                  parm                    #msgid
     C*                  parm                    #msgtp
     C*                  parm                    #msgdt
     C*                  parm                    #pgmq
     C*                  parm                    #msgk
     C*                  if        #msgid <> '*CLEAR '
     C*                  add       1             msgk
     C*                  write     msgrec
     C*                  endif
     C*                  eval      #msgdt = *blanks
     C*                  eval      $msgf = *blanks
     C*                  endsr
     *
     *    ZSCLR   Clear screen
     *
     C*    zsclr         begsr
     C*                  write     clrscr
     C*                  move      *on           sclear
     C*                  endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C*    zmqmsg        begsr
     C*                  add       1             msgk
     C*                  write     msgrec
     C*                  endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C*    zmsmsg        begsr
     C*                  if        $msgf = *blanks
     C*                  move      #msgf         $msgf
     C*                  endif
     C*                  call      'PUTMSG'
     C*                  parm                    $msgf
     C*                  parm                    #msgid
     C*                  parm                    #msgtp
     C*                  parm                    #msgdt
     C*                  parm      $pprg         #pgmq2           10
     C*                  parm                    #msgk             4
     C*                  eval      #msgdt = *blanks
     C*                  eval      $msgf = *blanks
     C*                  endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C*    zm0001        begsr
     C*                  if        $drisys2upd = 'D'
     C*                  eval      #msgid = 'DRI0001'
     C*                  else
     C*                  eval      #msgid = 'DRI0002'
     C*                  endif
     C*                  eval      #msgtp = '*DIAG'
     C*                  eval      #msgdt = $drimessage + $drireturn
     C*                                   + $dricommand + $drisubcmd
     C*                  exsr      zmpmsg
     C*                  endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C*    zm0001s       begsr
     C*                  if        $drisys2upd = 'D'
     C*                  eval      #msgid = 'DRI0001'
     C*                  else
     C*                  eval      #msgid = 'DRI0002'
     C*                  endif
     C*                  eval      #msgtp = '*DIAG'
     C*                  eval      #msgdt = $drimessage + $drireturn
     C*                                   + $dricommand + $drisubcmd
     C*                  exsr      zmsmsg
     C*                  eval      $pmsg = #msgk
     C*                  endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C*    zm0105        begsr
     C*                  eval      #msgid = 'PIR0105'
     C*                  eval      #msgtp = '*DIAG'
     C*                  eval      #msgdt = errmsg
     C*                  exsr      zmpmsg
     C*                  endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C*    zm0105s       begsr
     C*                  eval      #msgid = 'PIR0105'
     C*                  eval      #msgtp = '*DIAG'
     C*                  eval      #msgdt = errmsg
     C*                  exsr      zmsmsg
     C*                  eval      $pmsg = #msgk
     C*                  endsr

500b *----------------------------------------------------------------
500b *    PIR0110  Number must be greater than zero.
500b *----------------------------------------------------------------
500b
500b C*    zm0110        begsr
500b C*                  eval      #msgid = 'PIR0110'
500b C*                  eval      #msgtp = '*DIAG'
500b C*                  movea     errmsg        $md
500b C*                  exsr      zmpmsg
500b C*                  endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C*    zm9905        begsr
     C*                  move      'PIR9905'     #msgid
     C*                  move      '*DIAG  '     #msgtp
     C*                  eval      $md = *blanks
     C*                  exsr      zmpmsg
     C*                  endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C*    zm1001        begsr
     C*                  move      'PIR1001'     #msgid
     C*                  move      '*DIAG  '     #msgtp
     C*                  movea     errmsg        $md
     C*                  exsr      zmpmsg
     C*                  endsr
     *----------------------------------------------------------------
     *    PIR4001  Notify supervisor - Warning
     *
     C*    zm4001        begsr
     C*                  move      'PIR4001'     #msgid
     C*                  move      '*DIAG  '     #msgtp
     C*                  movea     errmsg        $md
     C*                  exsr      zmpmsg
     C*                  endsr
     *----------------------------------------------------------------
500b *    EQ41001  Invalid answer.
500b *
500b C*    zm4101        begsr
500b C*                  move      'EQ41001'     #msgid
500b C*                  move      '*DIAG  '     #msgtp
500b C*                  movea     errmsg        $md
500b C*                  exsr      zmpmsg
500b C*                  endsr
     *----------------------------------------------------------------
500b *    EQ41002  Value entered must be greater than existing value
     *
500b C*    zm4102        begsr
500b C*                  move      'EQ41002'     #msgid
500b C*                  move      '*DIAG  '     #msgtp
500b C*                  movea     errmsg        $md
500b C*                  exsr      zmpmsg
500b C*                  endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     C*    zm71          begsr
     C*                  move      'PIR7971'     #msgid
     C*                  move      '*DIAG  '     #msgtp
     C*                  move      *blanks       $md
     C*                  exsr      zmpmsg
     C*                  endsr
     *
     *----------------------------------------------------------------
     *
     *  EOS
     *
