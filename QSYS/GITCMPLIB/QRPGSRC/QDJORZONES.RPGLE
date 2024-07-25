     Hcopyright('(c) Copyright BFC Software, Inc - 2008')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     Htruncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)

     *----------------------------------------------------------------
     *
     *  QDJORZONES  Q&D to copy zones for TRUCK3 to all other zones
     *  29 January 2008
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Ftruckh    if   e           k disk
     Fzoneh     uf a e           k disk
     Fzoned1    uf a e           k disk
     Foptionz   uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D kywhse          s                   like(thwhse)
     D kytruk          s                   like(thtruk)
     D kycode          s                   like(opzcod)

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $cmd              8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Get out if proper command is not sent in.

     C                   if        $cmd <> '*UPDATE'
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     * Delete all existing zone records.

     C                   exsr      delZH
     C                   exsr      delZD
     C                   exsr      delOZ

     * Loop through all trucks

     C                   dow       1 = 1

     C                   read      truckh
     C                   if        %eof
     C                   leave
     C                   endif

     *    Skip WILLCALL and TRUCK3.

     C                   if        thtruk = 'WILLCALL'
     C                             or thtruk = 'TRUCK3'
     C                   iter
     C                   endif

     *    Create zone records for truck.

     C                   exsr      writeZH
     C                   exsr      writeZD
     C                   exsr      writeOZ

     C                   enddo

     * Bye, Bye.

     C                   eval      *inlr = *on

     *------------------------------------------------------------------
     * *INZSR
     *------------------------------------------------------------------

     C     *inzsr        begsr
     C     keyzh         klist
     C                   kfld                    kywhse
     C                   kfld                    kytruk
     C     keyoz         klist
     C                   kfld                    kycode
     C                   endsr

     *------------------------------------------------------------------
     * delZH  - Delete Zone Header records
     *------------------------------------------------------------------

     C     delZH         begsr

     C                   dow       1 = 1

     C                   read      zhrec
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zhtruk <> 'WILLCALL'
     C                             and zhtruk <> 'TRUCK3'
     C                   delete    zhrec
     C                   endif

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * delZD  - Delete Zone Detail records
     *------------------------------------------------------------------

     C     delZD         begsr

     C                   dow       1 = 1

     C                   read      zdrec
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zdtruk <> 'WILLCALL'
     C                             and zdtruk <> 'TRUCK3'
     C                   delete    zdrec
     C                   endif

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * delOZ  - Delete OptionZ records
     *------------------------------------------------------------------

     C     delOZ         begsr

     C                   dow       1 = 1

     C                   read      opzrec
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        opztrk <> 'WILLCALL'
     C                             and opztrk <> 'TRUCK3'
     C                   delete    opzrec
     C                   endif

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * writeZH  - Create Zone Header records
     *------------------------------------------------------------------

     C     writeZH       begsr

     C                   eval      kywhse = 1
     C                   eval      kytruk = 'TRUCK3'
     C     keyzh         setll     zhrec
     C                   dow       1 = 1

     C     keyzh         reade     zhrec
     C                   if        %eof
     C                   leave
     C                   endif

     C                   eval      zhtruk = thtruk
     C                   write     zhrec

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * writeZD  - Create Zone Detail records
     *------------------------------------------------------------------

     C     writeZD       begsr

     C                   eval      kywhse = 1
     C                   eval      kytruk = 'TRUCK3'
     C     keyzh         setll     zdrec
     C                   dow       1 = 1

     C     keyzh         reade     zdrec
     C                   if        %eof
     C                   leave
     C                   endif

     C                   eval      zdtruk = thtruk
     C                   write     zdrec

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * writeOZ  - Create OptionZ records
     *------------------------------------------------------------------

     C     writeOZ       begsr

     C                   eval      kycode = ' '
     C     keyoz         setll     opzrec
     C                   dow       1 = 1

     C     keyoz         reade     opzrec
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        opztrk <> 'TRUCK3'
     C                   iter
     C                   endif

     C                   eval      opztrk = thtruk
     C                   write     opzrec

     C                   enddo

     C                   endsr
