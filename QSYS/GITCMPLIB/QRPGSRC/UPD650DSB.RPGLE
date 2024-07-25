     F*----------------------------------------------------------------
     F*   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  UPD650DSB   Add RCVPO and RCVRTN tasks
     F*  04 November 2014
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
650A F*  11/04/14  DAS  6.50
     F*    - Created
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     Ftask      uf a e           k disk
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
500gAD $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     D*
     D*   Redefine key
     D*
     D  $lcode                19     24
     D  $ltlvl                25     25
     C*----------------------------------------------------------------
     C*  Main line
     C*
      /free

        $lcode = 'RCVPO';
        exsr AddTask;

        $lcode = 'RCVRTN';
        exsr AddTask;

        return;
      /end-free

     *----------------------------------------------------------------
     *  AddTask   Add/Update Task
     *----------------------------------------------------------------

      /free
       begsr AddTask;

         // Get record if it exists

         chain ($lcode) task;

         // Initialize fields

         select;

           when $lcode = 'RCVPO';
             tkdesc = 'Receiving';
             tkcat  = 'RECV';
             tksub  = 'RCV';
             tktype = 'D';
             tkstd  = 'Y';
             tktlvl = 'S';
             tkusrc = 'N';
             tktrkc = 'Y';
             tktrkw = 'Y';
             tktrkp = 'Y';
             tktrk1 = 'Y';
             tkdsc1 = 'Pallet';
             tktrk2 = 'N';
             tkdsc2 = ' ';
             tktrk3 = 'N';
             tkdsc3 = ' ';

           when $lcode = 'RCVRTN';
             tkdesc = 'Returns';
             tkcat  = 'RECV';
             tksub  = 'RCV';
             tktype = 'D';
             tkstd  = 'Y';
             tktlvl = 'S';
             tkusrc = 'N';
             tktrkc = 'Y';
             tktrkw = 'Y';
             tktrkp = 'Y';
             tktrk1 = 'Y';
             tkdsc1 = 'Pallet';
             tktrk2 = 'N';
             tkdsc2 = ' ';
             tktrk3 = 'N';
             tkdsc3 = ' ';

         endsl;

         // Add/Update record

         if not %found;
           write(e) tkrec;
         else;
           update(e) tkrec;
         endif;

         // Add task detail records

         exsr AddTaskDetail;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddTaskDetail   Add task detail records
     *----------------------------------------------------------------

      /free
       begsr AddTaskDetail;

         $lcmd  = '*ADD';
         $lcode = tkcode;
         $ltlvl = tktlvl;

      /end-free

     c                   call      'CRTTSK'
     c                   parm                    $lparm

      /free
       endsr;
      /end-free
