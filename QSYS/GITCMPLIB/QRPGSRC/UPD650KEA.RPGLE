      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  KITCONV  Update KITCOMP to include On-Demand Slot, KITITEM
     *           as well as blanking On-Demand Slot in Itemfld
     *  21 February 2013
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fpiritem   if   e           k disk
     F                                     infds(file1ds)
     Fkitcomp   uf   e           k disk
     F                                     infds(file12ds)
     Fkititem   uf a e           k disk
     F                                     infds(file15ds)
     FItemfld   uf   e           k disk
     F                                     infds(file8ds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     D errmsg          s             50
     d save_odrs       s             12
     d whcode          s              3  0
     d whdesc          s             30

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
     *  File Info Data Structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#file1ds
      /COPY *libl/qcopysrc,C#file12ds
      /COPY *libl/qcopysrc,C#file15ds
      /COPY *libl/qcopysrc,C#file8ds

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       exsr zzinz;
       exsr rd_kitcomp;

       *inlr = *on;

      //-------------------------------------------------------------
      //  rd_Kitcomp  -  Read/Update Kitcomp with On-Demand and call
       //                  routines to add KITITEM and update ITEMFLD
      //
       begsr rd_KitComp;

          setll (whcode) kitcomp;
          if %equal;
             reade (whcode) kitcomp;
             dow not %eof(kitcomp);
                chain (whcode:kcitem) KitItem;
                // only issue updates if item not found in KITITEM
                if not %found(KitItem);
                   exsr update_itemfld;
                   exsr create_kititem;
                   kcdisp = Save_odrs;
                   update kcrec;
                endif;
                reade (whcode) kitcomp;
             enddo;
          endif;
       endsr;

      //-------------------------------------------------------------
      //
      //   update_itemfld - Blank out On-Demand Slot (IFODRSLOT) and
      //     capture to place in new Kitcomp file layout (KCDISP)
      //
       begsr update_itemfld;
          chain (whcode:kcitem) itemfld;
          if %found(itemfld);
             save_odrs = ifodrslot;
             ifodrslot = ' ';
             update ifrec;
          endif;
       endsr;
      //-------------------------------------------------------------
      //
      //  create_newKitItem - Write to the newly created KitItem file
      //    that has component (Parent) items that make up a Repack
      //    item.  The old quantities per parent will be written to
      //    this file and a quantity of 1 will be written to KICOMP
      //    in field qty1
      //
       begsr create_KitItem;
          chain (whcode:kcitem) KitItem;
          if not %found(KitItem);
             clear kirec;
             kiwhse = kcwhse;
             kiitem = kcitem;
             kidisp = save_odrs;
             kiqty1 = 1;
             kiqty2 = 0;
             kiqty3 = 0;
             if save_odrs <> ' ';
                kirptp = '2';
             else;
                kirptp = '1';
             endif;
             write kirec;
          endif;
       endsr;
      /end-free
     *---------------------------------------------------------------
     *    zzinz - Program Initialization
     *
     c     zzinz         begsr
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     itwhse        parm      0             #whse             3 0
     C                   eval      whcode = itwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = itwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $lerm         errmsg
     C                   else
     C                   eval      whcode = itwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endsr
