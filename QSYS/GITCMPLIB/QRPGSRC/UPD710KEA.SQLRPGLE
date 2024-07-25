      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  Create new Tasks used by Production Module for EPM
     *  02 October 2017
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
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
     *  Program parameters
     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $lcode                37     38
     D  $ltype                39     39

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

                         *inlr = *on;
         // *****************************************************//
         // ****  Add new EPM Tasks for Production Module        //
         // *****************************************************//
         // Scale Operators
         EXEC SQL
           INSERT INTO task
             values('SCALE','Prod Module Scale Operators','PROD','SCALE',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Replenishment Task for Production
         EXEC SQL
           INSERT INTO task
             values('REPLPD','Replenishment - Production','PROD','REPL',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Putaway Task for Production
         EXEC SQL
           INSERT INTO task
            values('PUTPD','Putaway Production - Pallet','PROD','PUTAWY',
                    'D','Y','S','N','Y','Y','Y','Y','PALLET','N',' ','N',' ');

         // General Production Labor
         EXEC SQL
           INSERT INTO task
            values('GEN','General Production Labor','PROD','GEN',
                   'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Lumper Production Labor
         EXEC SQL
           INSERT INTO task
            values('LUMPPD','Lumper Production Pallets','PROD','LUMP',
                    'D','Y','S','N','Y','Y','Y','Y','PALLET','N',' ','N',' ');

         // Skilled Labor Force
         EXEC SQL
           INSERT INTO task
            values('SKILL','Skilled Labor - Production','PROD','SKILL',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Prod Module Planning
         EXEC SQL
           INSERT INTO task
            values('PLAN','Prod Module Planning','PROD','PLAN',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Prod Module Work Order Management
         EXEC SQL
           INSERT INTO task
            values('MWO','Prod Module Work Order Mgmt','PROD','MGMT',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');

         // Prod Module Replenishment Management
         EXEC SQL
           INSERT INTO task
            values('MRPL','Prod Module Replen Mgmt','PROD','MGMT',
                    'D','Y','D','N','Y','Y','Y','N',' ','N',' ','N',' ');
      /end-free
