      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  Itemlnk  Create records in ItemLnk from KITCOMP records for
     *           Repack Items if corresponding records are not found
     *           This ONLY HAD to Run at Green Leaf because we
     *           originally decided to no longer have Itemlnk records
     *           for Repack Items with release 6.50 but then decided
     *           to include them with a different key. If new installs
     *           never have Itemlnk records removed we will be OK
     *  28 August 2013
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fkitcomp   if   e           k disk
     Fitemlnk   uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     D errmsg          s             50
     d save_odrs       s             12
     d whcode          s              3  0

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

       exsr zzinz;
       exsr rd_kitcomp;

       *inlr = *on;

      //-------------------------------------------------------------
      //  rd_Kitcomp  -  Read Repack parent information from KITCOMP
       //                  and create respective records in Itemlnk
       //                  if not found
      //
       begsr rd_KitComp;

          setll (whcode) kitcomp;
          if %equal;
             reade (whcode) kitcomp;
             dow not %eof(kitcomp);
                chain (whcode:kcitem:kccitm) itemlnk;
                // only issue updates if record not found in Itemlnk
                if not %found(Itemlnk);
                   ilwhse = whcode;
                   ilitem = kcitem;
                   ilitm2 = kccitm;
                   ilitm3 = ' ';
                   write ilrec;
                endif;
                reade (whcode) kitcomp;
             enddo;
          endif;
       endsr;
      /end-free
     *---------------------------------------------------------------
     *    zzinz - Program Initialization
     *
     c     zzinz         begsr
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     whcode        parm      0             #whse             3 0
     C                   endsr
