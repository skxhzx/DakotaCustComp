      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RpkUsrSpc   Manage User Space Repack Array Calls
     *  15 March 2013
     *  Kenneth Elder
     *
650 A*    03/15/13  KDE  6.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
     *
     *  Data Structure for Repack data elements
     *  Pointer to the auto-extending user space Repack array
     *     found in QTEMP/aryRPD
     D ptrRPD          s               *
     *  Dynamically allocated array stored in the user space
     D RepackData      ds                  based(ptrRPD)
     D aryRPD                              dim(700)
     d  aeitem                       15a   overlay(aryRPD:*next)
     D  aedelcd                       1a   overlay(aryRPD:*next)
     D  aesitm2                      15a   overlay(aryRPD:*next)
     D  aesdisp                      12a   overlay(aryRPD:*next)
     D  aesqty1                       3p 0 overlay(aryRPD:*next)
     D  aesum1                        2a   overlay(aryRPD:*next)
     D  aesqty2                       3p 0 overlay(aryRPD:*next)
     D  aesum2                        2a   overlay(aryRPD:*next)
     D  aesqty3                       3p 0 overlay(aryRPD:*next)
     D  aesum3                        2a   overlay(aryRPD:*next)
     D  aerptp                        1a   overlay(aryRPD:*next)
     D  aedisp                       12a   overlay(aryRPD:*next)
     D  aerqty1                       3p 0 overlay(aryRPD:*next)
     D  aerum1                        2a   overlay(aryRPD:*next)
     D  aerqty2                       3p 0 overlay(aryRPD:*next)
     D  aerum2                        2a   overlay(aryRPD:*next)
     d  aesitpe                       1a   overlay(aryRPD:*next)
     D  aerqty3                       3p 0 overlay(aryRPD:*next)
     D  aerum3                        2a   overlay(aryRPD:*next)
     D  aearyrec                      5  0 overlay(aryRPD:*next)
     *
     *   API to create a user space object

     D CreateUserSpace...
     D                 pr                  extpgm('QUSCRTUS')
     D   NameAndLib                  20a   const
     D   ExtAttr                     10a   const
     D   InitSize                    10i 0 const
     D   InitValue                    1a   const
     D   PublicAut                   10a   const
     D   Description                 50a   const
     D   Replace                     10a   const
     D   ErrorStruct                 16a

     D ChangeUserSpaceAttributes...
     *   API to change user space object attributes
     D                 pr                  extpgm('QUSCUSAT')
     D   LibraryName                 10a
     D   NameAndLib                  20a   const
     D   Attributes                  10a   const
     D   ErrorStruct                 16a

     D AttrList        ds                  qualified
     D  Size                         10i 0
     D  Key                          10i 0
     D  DataLength                   10i 0
     D  Data                          1a

     D SpaceName       s             20a   inz('ARYRPD    QTEMP')
     D RtnLib          s             10a
     D ErrorStruct     s             16a   inz(*allx'00')

     *
     *   API to retrieve a pointer to the user space
     D RtvPtrToUsrSpc  pr                  extpgm('QUSPTRUS')
     D   Name                        20a   const
     D   Ptr                           *
     D   Qusec                             LikeDS(Qusec)
     * API to delete a user space
     D DltUsrSpc       pr                  ExtPgm('QUSDLTUS')
     D   SpaceName                   20A   Const
     D   Errorcde                 32767A

     dQusec            ds
     d qusbprv                 1      4b 0
     d qusbavl                 5      8b 0
     d qusei                   9     15
     d quserved               16     16

     D saveVer#        s                   like($slver#)
     d loop            s              3  0
     D drierr          s               n
     D pwhse           s              3  0
     D chk4err         s               n
     D zmsflag         s               n
     D Errorcde        s          32767a

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pcmd  - Command
     *     pItem - Repack Item
     *
     *   Return Value:
     *     perror     -  Error Status
     *----------------------------------------------------------------

     C     *entry        plist
     c                   parm                    pwhse
     C                   parm                    pItem            15
     C                   parm                    pcmd              8
     C                   parm                    prtn              8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms
       prtn = '*OK';

       select;

          when pcmd = '*SETUP';
             exsr CrtUsrSpace;

          when pcmd = '*DELETE';
             exsr DltUsrSpace;

          when pcmd = '*ITEM';
             exsr LoadItem;

       endsl;

       exsr zzzdriclose;
       *inlr = *on;
       return;

      /end-free

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  CrtUsrSpace - Create User Space for Repack Item Array
     *----------------------------------------------------------------

      /free
       begsr CrtUsrSpace;

         // Check to see if user space exists in QTEMP
         RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD: Qusec);

         if qusbavl>0;     // object not found
           // create user space if it did not exist
         CreateUserSpace (SpaceName: *blanks : 32767:
                          X'00': '*ALL': *blanks: '*YES':
                          ErrorStruct);
         AttrList.Size = 1;  // 1 attribute will be changed
         AttrList.Key = 3;   // 3=extensibility attribute
         AttrList.DataLength = 1;
         AttrList.Data = '1'; // user space is extensible

           // change to extend automatically as needed
         ChangeUserSpaceAttributes (RtnLib: SpaceName: AttrList:
                                    ErrorStruct);

         RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD : Qusec);
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DltUsrSpace - Delete User Space for Repack Item Array
     *----------------------------------------------------------------

      /free
       begsr DltUsrSpace;
         RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD: Qusec);
         if qusbavl<=0;     // object found
            DltUsrSpc(SpaceName: Errorcde);  //delete user space
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  LoadItem - Load Repack Item Array for processing
     *----------------------------------------------------------------

      /free
       begsr LoadItem;

          exsr CrtUsrSpace; //ensure user space exists
          %subarr(aryRPD:1:%elem(aryRPD)) = *loval; //initialize array

          exsr clr$item;
          $itwhse = pwhse;
          $ititem = pitem;  //pass repack item to have array loaded

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETMAIN';
          $drisys2upd = 'D';
          chk4err = *on;
          zmsflag = *off;
          exsr zzzdricop;
          if not drierr;
             // DRIITEM loaded the KIT array since no errors
             // requesting program should only have to establish pointer
             // IT116 can be used as an example.
          endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  DRI INTERFACE routines
     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
