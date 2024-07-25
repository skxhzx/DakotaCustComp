      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RTNTRN  -  Return Transaction number for Return with empty Tran#
     *  26 November 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
     * ------------------------------------------------------------------
416 A*    11/26/18  KDE  7.20
     *      - Created.  Pulled code from RN161A (ZGTRAN)
     *
730aA*    07/25/19  RBD  7.30a
     *      - Fix: Instead of showing returns user as selector when
     *        returns transaction is zero take the trans found with
     *        pord and get ptemp#, then uscode, uslnam and usfnam.
     *
750aA*    03/23/21  RBD  7.50a
     *      - Put selector at beginning of out string so it can be
     *        used in R19000 returns report to sort by selector.
     *      - Default selector to n/f when not found.
     *      - Added logic to get selector from transaction if not zero,
     *        was blank before.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D orrec         E Ds                  Extname(orrtn)
     D ohrec         E Ds                  Extname(ordh)
730aAD ptrec         E ds                  extname(pirtran) inz(*EXTDFT)
730aAD piruser       E ds                  extname(piruser) inz(*EXTDFT)

     *----------------------------------------------------------------
     *
     *  Variables
     *
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D fmdt            s              6  0
     D gendte          s              6  0
     D l               s              1  0
     D m               s                   like(l)
     d stat            s             10
     D todt            s              6  0
     D type            s              5
     D wkprtf          s             10
     D wkTrn           s              7  0
     d pOutStr         s           1024    varying
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
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
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pwhse             3 0
     C                   parm                    pord              7 0
     C                   parm                    pItem            15
     C                   parm                    pRtnCd            2
     C                   parm                    pTrn#             7 0
     C                   parm                    poutstr
     *  Get record passed in
      /free
          wkTrn=*zeros;
          orrusr=*blanks;
          if pTrn#=*zeros;
            exec sql select * into :orrec
                  from orrtn
                   where orwhse=:pwhse and orord=:pord and
                         oritem=:pitem and orrcod=:pRtnCd
                       fetch first row only;
            if sqlstt = '00000' and ortrn#=0;
               // now get Dakota Trans# from Label file
               exec sql select lbTrn# into :wkTrn
                     from label93 where lbwhse=:pWhse and
                        lbord=(select ohord from ordh where
                        ohwhse=:pWhse and ohcord=:pOrd
                         order by lbtrn# desc
                         fetch first row only) and lbitem=:pItem;

730aA          exec sql select pttrn#, ptemp#, usemp#, usfnam, uslnam
730aA                   into :pttrn#, :ptemp#, :usemp#, :usfnam, :uslnam
730aA                   from pirtran
730aA                   left outer join piruser
730aA                     on usemp# = ptemp#
730aA                   where ptwhse = :pwhse
730aA                     and pttrn# = :wktrn;

            endif;
750aA     else;
750aA        exec sql select pttrn#, ptemp#, usemp#, usfnam, uslnam
750aA                 into :pttrn#, :ptemp#, :usemp#, :usfnam, :uslnam
750aA                 from pirtran
750aA                 left outer join piruser
750aA                   on usemp# = ptemp#
750aA                 where ptwhse = :pwhse
750aA                   and pttrn# = :pTrn#;

          endif;
750aA     if usfnam = *blanks and uslnam = *blanks;
750aA       uslnam = 'N/F';
750aA     endif;
      /end-free
      /free
             // Build return json string
710aA   pOutStr = '{'
750aD     //+  '"trn":"'  + %char(wkTrn) + '",'
             //+  '"seltor":"'  + %trim(orrusr) + '"}';
750aM          +  '"seltor":"'  + %trim(usfnam) + ' ' + %trim(uslnam)+ '",'
750aA          +  '"trn":"'  + %char(wkTrn) + '"}';
               *inlr=*on;
               return;
      /end-free
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *inzsr        begsr
     C*
     C                   endsr
