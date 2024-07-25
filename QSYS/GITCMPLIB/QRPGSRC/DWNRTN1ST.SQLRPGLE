      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  Create File with daily returns
     *  5 February 2016
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700a *    02/05/16  GJA  7.00a
     *      - Created.
     *
710a *    12/22/17  MR   7.10a
     *      - Add email and pics parms to GETEMPL.
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Forrtn     if   e           k disk
     Frtndwn    o  a e           k disk

      *----------------------------------------------------------------
      * Function prototypes.
      *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.getempl
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

      *
      *----------------------------------------------------------------
      * Fields used in GETUSER call.
      *----------------------------------------------------------------
     D $user           s             10
     D $emp#           s              5  0
     D $whse           s              3  0
     D $code           s             10
     D $fnam           s             15
     D $init           s              1
     D $lnam           s             20
     D $whdp           s              5
     D $styp           s              1
     D $shft           s              6
     D $crew           s              6
     D $nhrs           s              3  1
     D $rtn            s              8
     D $bpu            s              1
     D $lng            s              2
710aAD $email          s              1
710aAD $pics           s              1
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)
SVL A
SVL A*----------------------------------------------------------------
SVL A*  Date Conversion DS
SVL A*----------------------------------------------------------------
SVL A
SVL AD @cvtdt          c                   const('CVTDTE')
SVL A*
SVL AD $cvtdt          ds
SVL AD  $cvcmd                 1      8
SVL AD  $cvprg                 9     18
SVL AD  $cvd6i                19     24
SVL AD  $cvd8i                25     32
SVL AD  $cvd6o                33     38  0
SVL AD  $cvd8o                39     46  0
SVL AD  $cvsto                47     64
SVL AD  $cvrtn                65     72
SVL AD  $cverm                73    132
SVL AD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D lbrec         E Ds                  Extname(label)
     D llrec         E Ds                  Extname(liclog)
     D ohrec         E Ds                  Extname(ordh)
     D lborec        E Ds                  Extname(labeldo)
     D rurec         E Ds                  Extname(runner)
     D ptrec         E Ds                  Extname(pirtran)

     *----------------------------------------------------------------
     *  Work Variables
     *----------------------------------------------------------------

SVL AD today           s               d
     D chkdte          s                   like(orrdte)
     D chk4err         s               n
     D zmflag          s               n
     D zmsflag         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        dou forever <> forever;
          read orrtn;
          if %eof(orrtn);
            leave;
          endif;
        //if orrdte <> chkdte;
        //  iter;
        //endif;

          rdwwhse = orwhse;
          rdword  = orord;
          rdwitem = oritem;
          rdwqty1 = orqty1;
          rdwqty2 = orqty2;
          rdwqty3 = orqty3;
          rdwcwtr = orcwtr;
          rdwrdte = orrdte;
          rdwrtim = orrtim;
          rdwrusr = orrusr;
          rdwpbat = orpbat;
          $code = orrusr;
          $whse = orwhse;
          getuser($code: $whse: $emp#: $fnam: $init: $lnam: $whdp:
                  $styp: $shft: $crew: $nhrs: $rtn: $bpu: $lng);
          if $rtn = '*ERROR';
            error = *on;
            rdwrnam = *blanks;
          else;
            rdwrnam = %trim($lnam) + ', ' + %trim($fnam);
          endif;
          rdwtrn# = ortrn#;
          rdwcitm = orcitm;
          rdwrcod = orrcod;
          rdwoord = oroord;
          rdwdcod = ordcod;
          rdwiinv = oriinv;
          rdwolb# = orolb#;
          rdwinv# = orinv#;
          rdwrmem = orrmem;
          rdwslot = orslot;
          rdwudte = orudte;
          rdwutim = orutim;
          rdwwhol = orwhol;

          // label file
          exec sql select * into :lbrec
              from label
              where lbwhse = :orWhse
                and lbitem = :oritem
                and lbpbat = :orpbat;

          If sqlstt = sqlSuccess;
            // successful
            rdwlbord = lbord;
            rdwlblbl#= lblbl#;
            rdwlbtrn#= lbtrn#;
          else;
           rdwlbord = *zeros;
           rdwlblbl#= *zeros;
           rdwlbtrn#= *zeros;
          endif;

          // ordh file
          exec sql select * into :ohrec
              from ordh
              where ohwhse = :orWhse
                and ohcord = :orord;

          If sqlstt = sqlSuccess;
            // successful
            rdwohord = ohord;
            rdwohrte = ohrte;
            rdwohcnam = ohcnam;
            rdwohcord = ohcord;
            rdwohcust = ohcust;
          else;
            rdwohord = *zeros;
            rdwohrte = *blanks;
            rdwohcnam = *blanks;
            rdwohcord = *zeros;
            rdwohcust = *zeros;
          endif;

          // label file
          If orolb# = *zeros;
            exec sql select * into :lbrec
                from label
                where lbwhse = :orWhse
                  and lbitem = :oritem
                  and lbord  = :rdwohord;

            If sqlstt = sqlSuccess;
              // successful
              rdwolb# = lblbl#;
              rdwtrn# = lbtrn#;
              rdwlqty = lbqpck;
              rdwutyp = lbutyp;
            else;
              rdwlqty = *zeros;
              rdwutyp = *blanks;
              rdwolb# = *zeros;
              rdwtrn# = *zeros;
            endif;
          endif;

          // labeldo file
          rdwsusr = *zeros;
          rdwsunam = *blanks;
          rdwoqty = *zeros;
          rdwsqty = *zeros;
          rdwnnam = *blanks;
          rdwnusr = *zeros;
          rdwnqty = *zeros;
          rdwntrn = *zeros;
          exec sql select * into :lborec
              from labeldo
              where lbolbl# = :rdwolb#;

          If sqlstt = sqlSuccess;
            // successful
            rdwoqty = lboqty;
            rdwsqty = lboqtys;
            rdwsusr = lboemp#;
            $emp# = lboemp#;
            $whse = lbowhse;
            getempl($emp#: $whse: $code: $fnam: $init: $lnam: $whdp:
710aD         //  $styp: $shft: $crew: $nhrs: $rtn: $bpu: $lng);
710aM             $styp: $shft: $crew: $nhrs: $rtn: $bpu: $lng:
710aA             $email: $pics);
            if $rtn = '*ERROR';
              error = *on;
              rdwsunam = *blanks;
            else;
              rdwsunam = %trim($lnam) + ', ' + %trim($fnam);
            endif;
            if lboqtys <> *zeros;
              // runner file
              exec sql select * into :rurec
                from runner
                where rulbl# = :rdwolb#;

              if sqlstt = sqlSuccess;
                // means you got the Runner info
                rdwntrn = rutrn#;
                rdwnqty = ruqyfd;
                exec sql select * into :ptrec
                  from pirtran
                  where pttrn# = :rutrn#;

                if sqlstt = sqlSuccess;
                  // successful
                  $code = *blanks;
                  $whse = ruwhse;
                  rdwnusr = ptemp#;
                  $emp# = ptemp#;
                  getempl($emp#: $whse: $code: $fnam: $init: $lnam: $whdp:
710aD               //$styp: $shft: $crew: $nhrs: $rtn: $bpu: $lng);
710aM               $styp: $shft: $crew: $nhrs: $rtn: $bpu: $lng:
710aA               $email: $pics);
                  if $rtn = '*ERROR';
                    error = *on;
                    rdwnnam = *blanks;
                  else;
                    rdwnnam = %trim($lnam) + ', ' + %trim($fnam);
                  endif;
                endif;
              else;
                  rdwnqty = *zeros;
                  rdwnnam = *blanks;
                  rdwnusr = *zeros;
                  rdwntrn = *zeros;
              endif;
            endif;
          endif;


          // get your liclog2 file
          rdwllact = *blanks;
          rdwlllcns = *blanks;
          exec sql select * into :llrec
              from liclog2
              where llwhse = :orWhse
                and lllbl# = :lblbl#
                and lltrn# = :lbtrn#
                and llaction = 'RTN';
          If sqlstt = sqlSuccess;
            // means you got the RTN
            rdwllact = llaction;
            rdwlllcns = lllcns;
          else;
            // you didn't find rtn look for rcv
            exec sql select * into :llrec
                from liclog2
                where llwhse = :orWhse
                  and lllbl# = :lblbl#
                  and lltrn# = :lbtrn#
                  and llaction = 'RCV';
            If sqlstt = sqlSuccess;
              // means you got the RCV
              rdwllact = llaction;
              rdwlllcns = lllcns;
            else;
              rdwllact = *blanks;
              rdwlllcns = *blanks;
            endif;
          endif;

          // need to get the ordered item info
          rdwitdesc = *blanks;
          rdwitdescc = *blanks;
          exsr clr$item;

          $itWhse = orwhse;
          $ititem = oritem;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error = *on;
            rdwitdesc = *blanks;
          else;
            rdwitdesc = $itdesc;
          endif;

          // need to get the picked item info
          if orcitm <> *blanks;
            exsr clr$item;

            $itWhse = orwhse;
            $ititem = orcitm;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETALL';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
              rdwitdescc = *blanks;
            else;
              rdwitdescc = $itdesc;
            endif;
          else;
            rdwitdescc = *blanks;
          endif;
          write rdwrec;
        enddo;

           *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *inzsr;

          today = %Date();
SVL A     today = today - %days(1);
SVL A     chkdte = %dec(today:*iso);

        endsr;
      /end-free

      *----------------------------------------------------------------
      *  clr$item  Clear $item data structure fields
      *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr


      *----------------------------------------------------------------
      *  zzzdricop  Call DRICOP
      *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

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
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
