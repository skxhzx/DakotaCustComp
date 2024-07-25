      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LTFIXDTE    Fix slot date from LICACTIVE file
     *  19 May 2009
     *  Dave Sommerville
     *
600 A*    05/19/09  DAS  6.00   P#00045
     *      - Created
730a *    12/20/19  RTR  7.30
     *      - Changed to use SLOT2 LF.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Files
     *----------------------------------------------------------------

730aDF*slot1     if   e           k disk
730aMFslot2     uf   e           k disk
     Flicactive1if   e           k disk
     Fpiritem   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse   -  Warehouse
     *      $pWhdp   -  Department (optional)
     *      $pDisp   -  Slot display (optional)
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pWhdp            5
     C                   parm                    $pDisp           12
     C                   parm                    $pDummy           1

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         // Ensure program was called from CL program, not from command.
         $pDummy = $pDummy;

         error = *off;
         i = 0;

         // Loop through requested slots

         select;
           when $pDisp <> ' ';
730aD      //setll ($pWhse: $pWhdp: $pDisp) slot1;
730aM        setll ($pWhse: $pWhdp: $pDisp) slot2;
           when $pWhdp <> ' ';
730aD      //setll ($pWhse: $pWhdp) slot1;
730aM        setll ($pWhse: $pWhdp) slot2;
           other;
730aD      //setll ($pWhse) slot1;
730aM        setll ($pWhse) slot2;
         endsl;

         dow forever = forever;

           select;
             when $pDisp <> ' ';
730aD        //reade ($pWhse: $pWhdp: $pDisp) slot1;
730aM          reade ($pWhse: $pWhdp: $pDisp) slot2;
             when $pWhdp <> ' ';
730aD        //reade ($pWhse: $pWhdp) slot1;
730aM          reade ($pWhse: $pWhdp) slot2;
             other;
730aD        //reade ($pWhse) slot1;
730aM          reade ($pWhse) slot2;
           endsl;

730aD    //if %eof(slot1);
730aM      if %eof(slot2);
             leave;
           endif;

           // Get item

           chain (slwhse: slitem) piritem;
           if not %found(piritem);
             itflgd = 'N';
           endif;

           // Get corresponding LICACTIVE record in FIFO order.

           setll (slwhse: slwhdp: sldisp: slitem) licactive1;

           if %equal(licactive1);

             reade (slwhse: slwhdp: sldisp: slitem) licactive1;

             if not %eof(licactive1);
               slentd = laentd;
730aD        //if itflgd = 'Y';
                 slexpd = laexpd;
730aD        //endif;
                 update(e) slrec;
               i += 1;
             endif;

           endif;

         enddo;

         *inlr = *on;
         return;

      /end-free
