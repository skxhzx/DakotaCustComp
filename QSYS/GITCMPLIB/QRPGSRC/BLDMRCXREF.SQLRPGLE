710 AH dftactgrp( *NO )
     H   actgrp( *NEW )
     H bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  BLDMRCXREF   Build Cross Reference data from MRC Development Objects
     *  Kenneth Elder                                   t
     *
710 A*    10/23/17  KDE  7.10
     *      - Created
     *
710aA*    11/03/17  KDE  7.10a
     *      - Changed to put (i) after any functions or procedures that
     *        that exist on the iSeries.  Add new field GWMENUS to
     *        show any menus object is called from.
     *
710bA*    11/08/17  KDE  7.10b
     *      - Changed include assigned name for Report object CALCULA fields
     *      - Add code to put (i) after procedures if found on iSeries
     *      - Add Timestamp with last modify date
     *
710cA*    11/22/17  KDE  7.10c
     *      - Changed to include objects in {a link href as BFCDAKOTA_
     *        abd BFCREPORTS_ as well as BFCDAKOTA. and BFCREPORTS.
     *----------------------------------------------------------------
     f*  Files
710kAfgloMenuItmif   e           k disk    usropn
710kDf*gloMenuWrkuf a e           k disk    usropn
710kAfmrcobjxrefuf a e           k disk    usropn
710kAfmrcTfrRecsuf a e           k disk    usropn
     ftextfile  uf   e           k disk    usropn

     D/copy QCOPYSRC,IFSIO_H

     D PATHTOLIST      s            256

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0

     D @__errno        pr              *   extproc( '__errno' )
     D strerror        pr              *   extproc( 'strerror' )
     D    errnum                     10i 0 value
     D errno           pr            10i 0

710bA *  Used to convert Unix time stamp to rpg timestamp
710bAd UnixToRpg       pr              z
710bAd UnixTime                      10u 0 value
710bAd Epoch           c                   z'1970-01-01-00.00.00'

710bA***    Used to Get time stamp values
710bAd GetCurrStamp    pr

710bAD GetMicroTime    pr
710bAD  $pmicrouc                      z
710bAD  $pmicrolocal                   z

     D* Local Variables
     d @command        s            350
710bAD bfcoffset       s              3  0 inz(0)
     D cmtRecord       S           2048
     D crlf            C                   const(x'0d25')
710bAd crtDate         s               z
710bAD CurrStamploc    s               z
710bAD CurrStampsys    s               z
710bAD CurrStampuc     s               z
710bAD CurrStampmn     s             26
     D dh              s               *
     D Dict            s             11
     d dlmtor          s              4
     D drnam           s            640
     D drnamj          s            640
     d endpos          s              5  0
710bAd fldary          s             30    dim(500)
710bAd fldnum          s              3  0
     d foundfields     s               n
     d foundFileFlds   s               n
     d  fromboth       c                    x'0d25'
     d  fromcc         c                    x'0D'
     d  fromlf         c                    x'25'
     d headercnt       s              1  0
     d headerread      s               n
     d lenname         s              3  0
     D Msg             s             52
710bAd mystat          s                   like(statds)
     D Name            s            640
710bMd objFields       s            750
     d objFiles        s            150
     d objFunc         s            150
     d objjava         s            200
     d objjquery       s            200
     d objMenu         s             50
     d objproc         s            150
     d objsessvar      s            200
     d objTitle        s            100
     d objType         s            150
     d objupdmrc       s              3
     d objVersion      s             10
     D PathFile        S            240
     d position        s              5  0
710bAd pos1            s              5  0
710bAd pos2            s              5  0
710bAd pos3            s              5  0
710bAd pos4            s              5  0
710bAd pos5            s              5  0
710bAD ucOffset        s              3  0
     D rc              s             10i 0
     d reccnt          s              5  0
     d returnCode      s             10i 0
     D Rpy             s              1
     D rtnVal          s             10u 0
     D RtvData         S          32767
     d sqlStmt         s           2048
     d sq              c                   const(x'7D')
     d  to             c                    '  '
     D VerName         s             52
710bMd wkFieldName     s            100
     d wkJava          s            200
     d wkjquery        s            200
     d wkloc           s             10
     d wkMenu          s             20
     d wkproc          s             10
     d wksessvar       s            200
     d wrkfile         s             10
     d wrkfunc         s             15
     D ZeroName        s            640

     d lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
     d upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     D stat_struct     ds
     D  st_other1                    48
     D  st_objtypea                  10
     D  st_other2                    68

     c     *entry        plist
     c                   parm                    objList          10
     c*                  goto      openfiles

      /free
       // clear flat text file and append this html to flat file
710bA  GetCurrStamp();
       @command = 'CLRPFM FILE(MRCOBJXREF)';
       returnCode = goCmd(%trim(@command));
       @command = 'CPYF FROMFILE(MRCTFRRECS) TOFILE(QTEMP/MRCTFRRECS) +
                 CRTFILE(*YES)';
       returnCode = goCmd(%trim(@command));
       @command = 'CHGPF FILE(QTEMP/MRCTFRRECS) SIZE(*NOMAX)';
       returnCode = goCmd(%trim(@command));
       @command = 'CLRPFM FILE(QTEMP/MRCTFRRECS)';
       returnCode = goCmd(%trim(@command));
       @command = 'CPYF FROMFILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE) +
                   CRTFILE(*YES)';
       returnCode = goCmd(%trim(@command));
       @command = 'CHGPF FILE(QTEMP/TEXTFILE) SIZE(*NOMAX)';
       returnCode = goCmd(%trim(@command));

      /end-free
     c     openfiles     tag
      /free
       if not %open(mrcobjxref);
          open mrcobjxref;
       endif;
       if not %open(glomenuitm);
          open glomenuitm;
       endif;

       if not %open(mrctfrrecs);
          @command = 'OVRDBF FILE(MRCTFRRECS) TOFILE(QTEMP/MRCTFRRECS)';
          returnCode = goCmd(%trim(@command));
          open mrctfrrecs;
       endif;
      /end-free
     c*                  goto      justlr
      /free

       //  Open up the directory.
       pathtoList = *blanks;

       dow pathtoList = pathtoList;

       // Change pathtolist to match customer path to BFCDAKOTA and
       // BFCREPORTS below.  Should generally only have to change
       // the three lines that have /MRC/development to the Tomcat
       // BFCDAKOTA directory on the customer box.  Remainder of
       // path should be the same
       select;
          when pathtolist=*blanks;
             pathtolist = '/MRC/development' +
                          '/m-power/mrcjava/WEB-INF/classes/' +
                          'BFCDAKOTA';
             dict='BFCDAKOTA.';
          when pathtolist = '/MRC/development' +
                          '/m-power/mrcjava/WEB-INF/classes/' +
                          'BFCDAKOTA';
             dict='BFCREPORTS.';
             pathtolist = '/MRC/development' +
                          '/m-power/mrcjava/WEB-INF/classes/' +
                          'BFCREPORTS';
       // end of pathtolist changes
          other;
               leave;
       endsl;

       dh = opendir( %trim(PATHTOLIST) ) ;
       if  dh = *NULL ;
          Msg = 'opendir: ' + %str( strerror( errno ) ) ;
          *inlr = *ON ;
          return ;
       endif ;

       //  Read each entry from the directory (in a loop)
       p_dirent = readdir( dh ) ;
       dow  p_dirent <> *NULL ;

          Name = %str( %addr( d_name ) ) ;
          Name = %xlate(lowercase:uppercase:Name);
          drnam = Name;
710bM     position = %scan('0S.HTML ':name:1);
          if position > 1;
             name=%subst(name:1:position);
             lenname=%len(%trim(name));

             if %subst(name:2:3) < '003'
               or (objList <> '*ALL' and objList<>'*all'
               and objlist<>'*All' and
               %subst(name:2:3) <> %subst(objList:2:3));
      /end-free
     c                   goto      skipentry
      /free
             endif;

             // if match of later version same primary object
             // of earlier version then remove earlier version
             // from MRCTFRRECS
             if lenname>2;
                zeroName = %trim(dict) + %subst(name:1:%len(%trim(name))-2);
                lenname = %len(%trim(zeroName));
                sqlStmt = 'delete from qtemp/mrctfrrecs ' +
                         'where substring(fciid,1,' + %char(lenname) +
                         ')=' + sq + %trim(zeroName) + sq;
                exec sql execute immediate :sqlStmt;
                lenname=%len(%trim(name))-2;
                zeroName = %subst(name:1:lenname) + '00';
             endif;
          else;
             // update or add MRCBLDXREF with current version from MRC directory
             position=0;
             select;
710bM           when %scan('1S.HTML ':name:1) > 1;
                   position = %scan('1S.HTML':name:1);
710bM           when %scan('2S.HTML ':name:1) > 1;
                   position = %scan('2S.HTML':name:1);
710bM           when %scan('3S.HTML ':name:1) > 1;
                   position = %scan('3S.HTML':name:1);
710bM           when %scan('4S.HTML ':name:1) > 1;
                   position = %scan('4S.HTML':name:1);
710bM           when %scan('5S.HTML ':name:1) > 1;
                   position = %scan('5S.HTML':name:1);
710bM           when %scan('6S.HTML ':name:1) > 1;
                   position = %scan('6S.HTML':name:1);
710bM           when %scan('7S.HTML ':name:1) > 1;
                   position = %scan('7S.HTML':name:1);
710bM           when %scan('8S.HTML ':name:1) > 1;
                   position = %scan('8S.HTML':name:1);
710bM           when %scan('9S.HTML ':name:1) > 1;
                   position = %scan('9S.HTML':name:1);
             endsl;
             if position > 1;
                name=%subst(name:1:position);
                lenname=%len(%trim(name));

                if %subst(name:2:3) < '003'
                  or (objList <> '*ALL' and objList<>'*all'
                  and objlist<>'*All' and
                  %subst(name:2:3) <> %subst(objList:2:3));
      /end-free
     c                   goto      skipentry
      /free
                endif;

                if lenname>2;
                   zeroName = %trim(dict) + %subst(name:1:%len(%trim(name))-2);
                   lenname = %len(%trim(zeroName));
                   sqlStmt = 'delete from qtemp/mrctfrrecs ' +
                            'where substring(fciid,1,' + %char(lenname) +
                            ')=' + sq + %trim(zeroName) + sq;
                   exec sql execute immediate :sqlStmt;
                   lenname=%len(%trim(name))-2;
                   zeroName = %subst(name:1:lenname) + '00';
                endif;
                verName = %trim(Dict) + Name ;
                exsr readHtml;
                exsr readmHtml;
                exsr readJava;
                exsr readXml;
                exsr readXmlRpts;
                exsr updmenu;

                msg = %trim(Dict) + zeroName ;
                chain (%trim(msg)) mrcobjxref;
                if %found(mrcobjxref);
                   chain (%trim(msg)) glomenuitm;
                   if %found(glomenuitm);
                      gwfound='Y';
                      gwipgm=%trim(gmipgm);
                   else;
                      gwfound='N';
                      gwipgm=%trim(msg);
                   endif;
                      gwFrmName = %trim(objTitle);
                      gwFrmType = %trim(objType);
                      gwVers = objVersion;
                      gwproc = %trim(objproc);
                      gwFiles = %trim(objFiles);
                      gwFunc = %trim(objFunc);
                      gwmrcupd = objupdmrc;
                      gwmenus = %trim(objMenu);
                      gwmrcflds = %trim(objFields);
                      gwjQuery = %trim(objjQuery);
                      gwJava = %trim(objjava);
                      gwsessvar = %trim(objsessvar);
710bA                 if crtdate>gwcrtdate;
710bA                    gwcrtdate = crtdate;
710bA                 endif;
                   if %trim(verName) > gwipgmmrc;
                      gwipgmmrc=%trim(verName);
                   endif;
                   eval gwicomp = 'S';
                   if gwipgm <> gwipgmmrc;
                   eval gwicomp = 'D';
                   endif;
                   update gwrec;
                else;
                   chain (%trim(msg)) glomenuitm;
                   if %found(glomenuitm);
                      gwfound='Y';
                      gwipgm=%trim(gmipgm);
                   else;
                      gwfound='N';
                      gwipgm=%trim(msg);
                   endif;
                   gwiid=%trim(msg);
                   gwipgmmrc=%trim(verName);
                   gwFrmName = %trim(objTitle);
                   gwFrmType = %trim(objType);
                   gwVers = objVersion;
                   gwproc = %trim(objproc);
                   gwFiles = %trim(objFiles);
                   gwsessvar = %trim(objsessvar);
                   gwFunc = %trim(objFunc);
                   gwMenus = objMenu;
                   gwmrcupd = objupdmrc;
                   gwmrcflds = %trim(objFields);
                   gwjQuery = %trim(objjQuery);
710bA              gwJava = %trim(objjava);
710bA              gwcrtdate = crtdate;
                   eval gwicomp = 'S';
                   if gwipgm <> gwipgmmrc;
                   eval gwicomp='D';
                   endif;
                   write gwrec;
                endif;
             endif;
      /end-free
     c                   goto      skipentry
      /free
          endif;
          rtnVal = stat( %trim(PATHTOLIST) + '/' + d_name :
                         %addr(stat_struct) ) ;

          if rtnVal = 0 ;
             if st_objTypea = '*DIR      ' ;

             // it's a directory, but there are
             // two cases we will ignore...
                if %str( %addr(d_name) ) <> '.'
                   AND
                   %str( %addr(d_name) ) <> '..' ;

                // process the directory entry...
                // (could process recursively here...)
                   Msg = 'Dir: ' + Name ;

                endif ;

             elseif st_objTypea = '*STMF     ' ;
             // it's a streamfile...
                VerName = %trim(Dict) + Name ;
                Msg = %trim(Dict) + zeroName ;
                exsr readHtml;
                exsr readmHtml;
                exsr readJava;
                exsr readXml;
                exsr readXmlRpts;
                exsr updmenu;
                // add to file with object name, Yes or No flag indicating whether
                // it is in Glomenuitm file, the current version in Glomenuitm file.
                chain (%trim(msg)) mrcobjxref;
                if %found(mrcobjxref);
                   chain (%trim(msg)) glomenuitm;
                   if %found(glomenuitm);
                      gwiid=gmiid;
                      gwfound='Y';
                      gwipgm=%trim(gmipgm);
                   else;
                      gwiid=%trim(msg);
                      gwfound='N';
                      gwipgm=%trim(verName);
                   endif;
                   gwFrmName = %trim(objTitle);
                   gwFrmType = %trim(objType);
                   gwVers = objVersion;
                   gwproc = %trim(objproc);
                   gwFiles = %trim(objFiles);
                   gwFunc = %trim(objFunc);
                   gwMenus = objMenu;
                   gwmrcupd = objupdmrc;
                   gwmrcflds = %trim(objFields);
                   gwjQuery = %trim(objjQuery);
                   gwJava = %trim(objjava);
                   gwsessvar = %trim(objsessvar);
710bA              if crtdate>gwcrtdate;
710bA                 gwcrtdate = crtdate;
710bA              endif;
                   if %trim(verName) > gwipgmmrc;
                      gwipgmmrc=%trim(verName);
                   endif;
                   eval gwicomp = 'S';
                   if gwipgm <> gwipgmmrc;
                   eval gwicomp = 'D';
                   endif;
                   update gwrec;
                else;
                   chain (%trim(msg)) glomenuitm;
                   if %found(glomenuitm);
                      gwiid=gmiid;
                      gwfound='Y';
                      gwipgm=%trim(gmipgm);
                   else;
                      gwiid=%trim(msg);
                      gwfound='N';
                      gwipgm=%trim(verName);
                   endif;
                   gwFrmName = %trim(objTitle);
                   gwFrmType = %trim(objType);
                   gwVers = objVersion;
                   gwproc = %trim(objproc);
                   gwFiles = %trim(objFiles);
                   gwFunc = %trim(objFunc);
                   gwMenus = objMenu;
                   gwJava = %trim(objjava);
                   gwmrcupd = objupdmrc;
                   gwmrcflds = %trim(objFields);
                   gwjQuery = %trim(objjQuery);
                   gwipgmmrc=%trim(verName);
                   gwsessvar = %trim(objsessvar);
710bA              gwcrtdate = crtdate;
                   eval gwicomp = 'S';
                   if gwipgm <> gwipgmmrc;
                   eval gwicomp = 'D';
                   endif;
                   write gwrec;
                endif;
             endif ;
          endif ;

      /end-free
     c     skipentry     tag
      /free
          p_dirent = readdir( dh ) ;
       enddo ;

       //  Close the directory
       rc = closedir( dh ) ;
       enddo;

       //  End Program

       // update mrcbldxref file with calls made within
       // calc specs and html json calls and control passed
      /end-free
     c     justlr        tag
      /free
       setll *loval mrctfrrecs;
       read mrctfrrecs;
       dow not %eof(mrctfrrecs);
          verName = %trim(fcdict) + '.' + %trim(fcpgm);
          lenname=%len(%trim(verName))-2;
          zeroName = %subst(verName:1:lenname) + '00';
          exec sql select gwipgm into :verName
                from mrcobjxref
               where gwiid=:zeroName;
          if sqlStt = '00000';
             lenname=%len(%trim(fciid))-2;
             zeroName = %subst(fciid:1:lenname) + '00';
             chain (%trim(zeroName)) mrcobjxref;
             if %found(mrcobjxref);
                verName = %xlate(lowercase:uppercase:verName);
                position = %scan('.':verName:1);
                verName = %subst(verName:position+1:%len(verName)-position-1);
710bA           @command = 'CHKOBJ OBJ(' +
710bA                       %trim(fcpgm) + ') OBJTYPE(*PGM)';
710bA           returnCode = goCmd(%trim(@command));
710bA           if returncode = 0;
710bA              if gwfunc=*blanks;
710bA                 gwfunc=%trim(verName) + '(i)';
710bA              else;
710bA                 if %scan(%trim(verName):gwfunc:1)=0;
710bA                    gwfunc=%trim(gwfunc) + ',' + %trim(verName) + '(i)';
710bA                 endif;
710bA              endif;
710bA           else;
710bA              // if function not found on iSeries then exclude (i)
710bA              if gwfunc=*blanks;
710bA                 gwfunc=%trim(verName);
710bA              else;
710bA                 if %scan(%trim(verName):gwfunc:1)=0;
710bA                    gwfunc=%trim(gwfunc) + ',' + %trim(verName);
710bA                 endif;
710bA              endif;
710bA           endif;
                update gwrec;
             endif;
          endif;
          delete fcrec;
          read mrctfrrecs;
       enddo;
       close mrctfrrecs;
       close glomenuitm;
       @command = 'DLTOVR FILE(MRCTFRRECS)';
       returnCode = goCmd(%trim(@command));
       close mrcobjxref;

       *inlr = *ON ;
       return ;

710bA   // ---------------------------------------------------- //
710bA   // -- convertDate - Convert Unix date to RPG date       //
710bA   // ---------------------------------------------------- //
710bA    begsr convertDate;
710bA
710bA      // Created Date
710bA      crtdate = z'1970-01-01-00.00.00';
710bA      crtDate = UnixToRpg(st_mtime);
710bA
710bA    endsr;
710bA
        // ---------------------------------------------------- //
        // -- updMenu - Update field with Menu called           //
        // ---------------------------------------------------- //
         begsr updMenu;
            objMenu=*blanks;
            sqlstmt = 'select distinct gmname from glomenu ' +
                      'where gmid like ' + sq + '%' +
                       %subst(verName:1:%len(%trim(verName))-2) +
                       '%' + sq;
            exec sql PREPARE mn FROM :SqlStmt;
            exec sql DECLARE menuc SCROLL CURSOR FOR mn;
            exec sql OPEN menuc;
            exec sql fetch first from menuc into :wkmenu;

            dow sqlStt = '00000';
               if objmenu = *blanks;
                  objmenu = %trim(wkmenu);
               else;
                  objmenu = %trim(objmenu) + ',' + %trim(wkmenu);
               endif;
               exec sql fetch next from menuc into :wkmenu;
            enddo;
            exec sql close menuc;

         endsr;

        // ---------------------------------------------------- //
        // -- readHtml - Read the Html file to update certain   //
        //    fields with informative date                      //
        // ---------------------------------------------------- //
         begsr readHtml;


              // clear flat text file and append this html to flat file
              @command = 'CLRPFM FILE(QTEMP/TEXTFILE)';
              returnCode = goCmd(%trim(@command));

              Pathfile = %trim(pathToList) + '/' + %trim(drnam);

              dlmtor = '*LF';
              dow 1 =1;
                 // create flatfile from html file using Carriage Return
                 // as delimiter first.  If that only returns one record
                 // meaning it must have been using Line Feed as the
                 // delimiter then change to *LF and try it
                 @command = 'CPYFRMIMPF FROMSTMF(' + sq +
                             %trim(PathFile) + sq + ') ' +
                            'TOFILE(QTEMP/TEXTFILE) RCDDLM(' +
                            %trim(dlmtor) + ') ' +
                            'RPLNULLVAL(*FLDDFT) FLDDLM(|)';
                 returnCode = GoCmd(%trim(@command));
                 exec sql select count(*) into :reccnt from qtemp/textfile;
                 if (sqlStt = '00000' and reccnt>20)
                      or dlmtor='*CR';
                    leave;
                 endif;
                 dlmtor='*CR';
              enddo;

              // now that the html file is easily readable simply
              // loop through looking for tags of information

               headerread=*off;
               objTitle = *blanks;
               objVersion = *blanks;
               objType = *blanks;
               objjQuery = *blanks;
               wkjQuery = *blanks;
               objjava = *blanks;
               wkjava = *blanks;
               objsessvar = *blanks;
               wksessvar = *blanks;

               if not %open(textfile);
                  @command = 'OVRDBF FILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE)';
                  returnCode = goCmd(%trim(@command));
                  open textfile;
               endif;
               read textfile;

               dow  not %eof(textfile);

                  // replace special chars with blanks
                  txLine = %xlate( fromcc: to : txLine);
                  txLine = %xlate( fromlf: to : txLine);
                  txLine = %xlate( fromboth: to : txLine);
                  // When headerread is on it means the <head><title> record
                  // was just processed.  We should read two records and
                  // poplate the type screen along with date and user created

                  // skip certain lines that contain no valuable data and
                  // cause issues getting form type record correctly in some cases
                  If %scan('meta':TxLine:1) > 0 or
                     %scan('#setting':TxLine:1) > 0;
      /end-free
     c                   goto      skiphtmlrd
      /free
                  endif;

                  // grab From Type, Date and person created
                  If %scan('<!--':TxLine:1) > 0 and %scan('-->':TxLine:1)>0;
                     // when begin and end of comment exist on one record
                     if objType=*blanks and
                        %scan('Created':TxLine:1) > 0;
                        position = %scan('<!--':TxLine:1);
                        position = position + 4;
                        if %scan('-->':TxLine:position) > 1;
                           endpos = %scan('-->':TxLine:position);
                           objType = %subst(TxLine:position:endpos-position);
                        endif;
                     endif;
                  else;
                     // otherwise when begin and end on separate records
                     // we read additional records till we find end and
                     // cat records together to get needed information
                     If %scan('<!--':TxLine:1) > 0 and objType=*blanks;
                        cmtRecord = %trim(TxLine);
                        dow not %eof(textfile);
                           read textfile;
                           cmtRecord = %trim(cmtRecord) + ' ' + %trim(TxLine);
                           if %scan('-->':cmtRecord:1) > 0;
                              if objType=*blanks and
                                 %scan('Created':cmtRecord:1) > 0;
                                 position = %scan('<!--':cmtRecord:1);
                                 position = position + 4;
                                 if %scan('-->':cmtRecord:position) > 1;
                                    endpos = %scan('-->':cmtRecord:position);
                                    objType = %subst(cmtRecord:position:
                                                endpos-position);
                                    // replace special chars with blanks
                                    objType = %xlate( fromcc: to : objType);
                                    objType = %xlate( fromlf: to : objType);
                                    objType = %xlate( fromboth: to : objType);
                                 endif;
                                 leave;
                              endif;
                           endif;
                        enddo;
                     endif;
                  endif;

                  // retrieve desired information
                  // first get Object Title from MRC Title
                  if objTitle=*blanks and %scan('<title>':TxLine:1) > 0;
                     position = %scan('<title>':TxLine:1);
                     if %scan('</title>':TxLine:position+6) > 1;
                        endpos=%scan('</title>':TxLine:position+6);
                        objTitle = %subst(TxLine:position+7:
                                   endpos - position - 7);
                     endif;
                  endif;

                  // if the Bfc Version is found populate Version
                  if objVersion=*blanks and (%scan('bfcVersion':TxLine:1) > 0
                           or %scan('bfcversion':TxLine:1) > 0
                           or %scan('bfc_Version':TxLine:1) > 0
                           or %scan('bfc_version':TxLine:1) > 0);
                     select;
                       when %scan('bfcVersion':TxLine:1) > 0;
                         position = %scan('bfcVersion':TxLine:1);
                       when %scan('bfcversion':TxLine:1) > 0;
                         position = %scan('bfcversion':TxLine:1);
                       when %scan('bfc_Version':TxLine:1) > 0;
                         position = %scan('bfc_Version':TxLine:1);
                       when %scan('bfc_version':TxLine:1) > 0;
                         position = %scan('bfc_version':TxLine:1);
                     endsl;
                     if %scan('"':TxLine:position) > 1;
                        position = %scan('"':TxLine:position);
                        if %scan('"':TxLine:position+1) > 1;
                           endpos=%scan('"':TxLine:position+1);
                       objVersion = %subst(TxLine:position+1:endpos-position-1);
                        endif;
                     endif;
                  endif;

                  // if the Bfc Title is found use it instead of MRC Title
                  if (%scan('bfcTitle':TxLine:1) > 0
                           or %scan('bfctitle':TxLine:1) > 0
                           or %scan('bfc_Title':TxLine:1) > 0
                           or %scan('bfc_title':TxLine:1) > 0);
                     select;
                       when %scan('bfcTitle':TxLine:1) > 0;
                         position = %scan('bfcTitle':TxLine:1);
                       when %scan('bfctitle':TxLine:1) > 0;
                         position = %scan('bfctitle':TxLine:1);
                       when %scan('bfc_Title':TxLine:1) > 0;
                         position = %scan('bfc_Title':TxLine:1);
                       when %scan('bfc_title':TxLine:1) > 0;
                         position = %scan('bfc_title':TxLine:1);
                     endsl;
                     if %scan('"':TxLine:position) > 1;
                        position = %scan('"':TxLine:position);
                        if %scan('"':TxLine:position+1) > 1;
                           endpos=%scan('"':TxLine:position+1);
                         objTitle = %subst(TxLine:position+1:endpos-position-1);
                           // leave;
                        endif;
                     endif;
                  endif;

                  // Look for Jquery method calls
                  select;
                    when %scan('jQuery.':txLine:1) > 0;
                       // jQuery.getJSON(bfcLink3....
                       if %scan('(':txLine:1) >0;
                          position = %scan('jQuery.':txLine:1);
                          endpos = %scan('(':txLine:position);
                          wkjQuery = '.' + %subst(txLine:position+7:
                                     (endpos)-(position+7));
                          if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                             if objjQuery=*blanks;
                                objjQuery = wkjQuery;
                             else;
                                objjQuery = %trim(objjQuery) + ',' +
                                            %trim(wkjQuery);
                             endif;
                          endif;
                       endif;
                    when %scan('jQuery(':txLine:1) > 0;
                       // jQuery('#trythis').show();
                       position = %scan('jQuery(':txLine:1);
                       if %scan(').':txLine:position+6) > 0;
                          position = %scan(').':txLine:position+6);
                          if %scan('(':txLine:position) > 0;
                             endpos = %scan('(':txLine:position+1);
                             wkjQuery = '.' + %subst(txLine:position+2:
                                        (endpos) - (position+2));
                             if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                                if objjQuery=*blanks;
                                   objjQuery = wkjQuery;
                                else;
                                   objjQuery = %trim(objjQuery) + ',' +
                                               %trim(wkjQuery);
                                endif;
                             endif;
                          endif;
                       endif;
                    when %scan('.':txLine:1) > 0;
                       // .success(function()......
                       position = %scan('.':txLine:1);
                       if %scan('(function()':txLine:position)>0;
                          endpos = %scan('(function()':txLine:position);
                          if (endpos - position) <= 10;
                             wkjQuery = '.' + %subst(txLine:position+1:
                                        (endpos) - (position+1));
                             if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                                if objjQuery=*blanks;
                                   objjQuery = wkjQuery;
                                else;
                                   objjQuery = %trim(objjQuery) + ',' +
                                               %trim(wkjQuery);
                                endif;
                             endif;
                          endif;
                       endif;
                  endsl;

                  // Look for Java method calls
                  select;
                    when %scan('.':txLine:1) > 0 and %scan('jQuery':txLine:1)=0;
                       // selWo.trim()   would trim field selWo
                       position = %scan('.':txLine:1);
                       if %scan('()':txLine:position) >0 and
                          (%scan('()':txLine:position)-position) <=8;
                          endpos = %scan('()':txLine:position);
                          wkjava = %trim(%subst(txLine:position+1:
                                     (endpos)-(position+1))) + '()';
                          if %scan(%trim(wkjava):objjava:1) = 0;
                             if objjava=*blanks;
                                objjava = wkjava;
                             else;
                                objjava = %trim(objjava) + ',' +
                                            %trim(wkjava);
                             endif;
                          endif;
                       endif;
                  endsl;

                  // Look for session Storage Variables
                  select;
710bA               // sessisonStorage.setItem('Mutiday');
710bA               when %scan('sessionStorage':txLine:1) > 0
710bA                    and (%scan('setItem':txLine:1) > 0 or
710bA                         %scan('getItem':txLine:1) > 0 or
710bA                         %scan('removeItem':txLine:1) > 0 or
710bA                         %scan('popArrayItem':txLine:1) > 0 or
710bA                         %scan('pushArrayItem':txLine:1)> 0);
710bA                  position = %scan('sessionStorage':txLine:1);
710bA                  if %scan('(':txLine:position) >0;
710bA                     position = %scan('(':txLine:position);
710bA                     pos1 = %scan(sq:txLine:position+2);
710bA                     pos2 = %scan('"':txLine:position+2);
710bA                     endpos=pos1;
710bA                     if pos2>*zeros and pos2<endpos;
710bA                        endpos=pos2;
710bA                     endif;
710bA                     if endpos<>0 and %subst(txLine:position-6:6)
710bA                             <>'jQuery';
                             wksessvar = %trim(%subst(txLine:position+2:
                                        (endpos)-(position+2)));
710bA                        if wksessVar <> *blanks;
710bA                           if %scan(%trim(wksessvar):objsessvar:1) = 0;
710bA                              if objsessvar=*blanks;
710bA                                 objsessvar = wksessvar;
710bA                              else;
710bA                                 objsessvar = %trim(objsessvar) + ',' +
710bA                                             %trim(wksessvar);
710bA                              endif;
                                endif;
                             endif;
                          endif;
                       endif;
710bA               when %scan('sessionStorage':txLine:1) > 0;
710bA                  // sessisonStorage.pItem  where the variable is like method
710bA                  position = %scan('sessionStorage':txLine:1);
710bA                  if %subst(txLine:position+14:1) = '.';
710bA                     position = %scan('.':txLine:position);
710bA                     pos1 = %scan(')':txLine:position);
710bA                     pos2 = %scan(' ':txLine:position);
710bA                     pos3 = %scan(';':txLine:position);
710bA                     pos4 = %scan('=':txLine:position);
710bA                     pos4 = %scan('"':txLine:position);
710bA                     endpos=pos1;
710bA                     if pos2>*zeros and pos2<endpos;
710bA                        endpos=pos2;
710bA                     endif;
710bA                     if pos3>*zeros and pos3<endpos;
710bA                        endpos=pos3;
710bA                     endif;
710bA                     if pos4>*zeros and pos4<endpos;
710bA                        endpos=pos4;
710bA                     endif;
710bA                     if pos5>*zeros and pos5<endpos;
710bA                        endpos=pos5;
710bA                     endif;
710bA                     if endpos<>0;
710bA                        wksessvar = %trim(%subst(txLine:position+1:
710bA                                   (endpos)-(position+1)));
710bA                        if wksessVar <> *blanks;
710bA                           if %scan(%trim(wksessvar):objsessvar:1) = 0;
710bA                              if objsessvar=*blanks;
710bA                                 objsessvar = wksessvar;
710bA                              else;
710bA                                 objsessvar = %trim(objsessvar) + ',' +
710bA                                             %trim(wksessvar);
710bA                              endif;
710bA                           endif;
710bA                        endif;
710bA                     endif;
710bA                  endif;
                  endsl;

                  // Look for Javascript and Html program calls/transfers
                  // search each line for BFCDAKOTA and the BFCREPORTS
                  // Loop until all occurences are found and processed
                  position = 1;
                  // BFCDAKOTA.
                  dow 1=1;
                     if %scan('BFCDAKOTA.':TxLine:position) > 0;
                        position = %scan('BFCDAKOTA.':TxLine:position);
                        if %subst(TxLine:position+10:1) = 'I' or
                           %subst(TxLine:position+10:1) = 'M' or
                           %subst(TxLine:position+10:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+11);
                           if (endpos - (position+11) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:9);
                              fcpgm = %subst(TxLine:position+10:endpos-position
                                                   -10);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCDAKOTA is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  // BFCDAKOTA_
                  position = 1;
                  dow 1=1;
                     if %scan('BFCDAKOTA_':TxLine:position) > 0;
                        position = %scan('BFCDAKOTA_':TxLine:position);
                        if %subst(TxLine:position+10:1) = 'I' or
                           %subst(TxLine:position+10:1) = 'M' or
                           %subst(TxLine:position+10:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+11);
                           if (endpos - (position+11) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:9);
                              fcpgm = %subst(TxLine:position+10:endpos-position
                                                   -10);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCDAKOTA is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  position = 1;
                  // BFCREPORTS.
                  dow 1=1;
                     if %scan('BFCREPORTS.':TxLine:position) > 0;
                        position = %scan('BFCREPORTS.':TxLine:position);
                        if %subst(TxLine:position+11:1) = 'I' or
                           %subst(TxLine:position+11:1) = 'M' or
                           %subst(TxLine:position+11:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+12);
                           if (endpos - (position+12) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:10);
                              fcpgm = %subst(TxLine:position+11:endpos-position
                                                   -11);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCREPORTS is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  position = 1;
                  // BFCREPORTS_
                  dow 1=1;
                     if %scan('BFCREPORTS_':TxLine:position) > 0;
                        position = %scan('BFCREPORTS_':TxLine:position);
                        if %subst(TxLine:position+11:1) = 'I' or
                           %subst(TxLine:position+11:1) = 'M' or
                           %subst(TxLine:position+11:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+12);
                           if (endpos - (position+12) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:10);
                              fcpgm = %subst(TxLine:position+11:endpos-position
                                                   -11);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCREPORTS is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

      /end-free
     c     skiphtmlrd    tag
      /free
                  read textfile;
               enddo;

            Close textfile;
            @command = 'DLTOVR FILE(TEXTFILE)';
            returnCode = goCmd(%trim(@command));

      /end-free
     c     endreadhtml   tag
      /free
            endsr;

        // ---------------------------------------------------- //
        // -- readmHtml - Read the Html file for Maintainer     //
        // ---------------------------------------------------- //
         begsr readmHtml;


              // clear flat text file and append this html to flat file
              @command = 'CLRPFM FILE(QTEMP/TEXTFILE)';
              returnCode = goCmd(%trim(@command));


              position = %scan('S.HTML':drnam:1);
              drnamj = drnam;
              %subst(drnamj:position:1)='M';
              Pathfile = %trim(pathToList) + '/' + %trim(drnam);

              dlmtor = '*LF';
              dow 1 =1;
                 // create flatfile from html file using Carriage Return
                 // as delimiter first.  If that only returns one record
                 // meaning it must have been using Line Feed as the
                 // delimiter then change to *LF and try it
                 @command = 'CPYFRMIMPF FROMSTMF(' + sq +
                             %trim(PathFile) + sq + ') ' +
                            'TOFILE(QTEMP/TEXTFILE) RCDDLM(' +
                            %trim(dlmtor) + ') ' +
                            'RPLNULLVAL(*FLDDFT) FLDDLM(|)';
                 returnCode = GoCmd(%trim(@command));
                 if returncode <> 0;
                    leavesr;
                 endif;
                 exec sql select count(*) into :reccnt from qtemp/textfile;
                 if (sqlStt = '00000' and reccnt>20)
                      or dlmtor='*CR';
                    leave;
                 endif;
                 dlmtor='*CR';
              enddo;

              // now that the html file is easily readable simply
              // loop through looking for tags of information

               headerread=*off;

               if not %open(textfile);
                  @command = 'OVRDBF FILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE)';
                  returnCode = goCmd(%trim(@command));
                  open textfile;
               endif;
               read textfile;

               dow  not %eof(textfile);

                  // replace special chars with blanks
                  txLine = %xlate( fromcc: to : txLine);
                  txLine = %xlate( fromlf: to : txLine);
                  txLine = %xlate( fromboth: to : txLine);
                  // When headerread is on it means the <head><title> record
                  // was just processed.  We should read two records and
                  // poplate the type screen along with date and user created

                  // skip certain lines that contain no valuable data and
                  // cause issues getting form type record correctly in some cases
                  If %scan('meta':TxLine:1) > 0 or
                     %scan('#setting':TxLine:1) > 0;
      /end-free
     c                   goto      skipmhtmlrd
      /free
                  endif;

                  // grab From Type, Date and person created
                  If %scan('<!--':TxLine:1) > 0 and %scan('-->':TxLine:1)>0;
                     // when begin and end of comment exist on one record
                     if objType=*blanks and
                        %scan('Created':TxLine:1) > 0;
                        position = %scan('<!--':TxLine:1);
                        position = position + 4;
                        if %scan('-->':TxLine:position) > 1;
                           endpos = %scan('-->':TxLine:position);
                           objType = %subst(TxLine:position:endpos-position);
                        endif;
                     endif;
                  else;
                     // otherwise when begin and end on separate records
                     // we read additional records till we find end and
                     // cat records together to get needed information
                     If %scan('<!--':TxLine:1) > 0 and objType=*blanks;
                        cmtRecord = %trim(TxLine);
                        dow not %eof(textfile);
                           read textfile;
                           cmtRecord = %trim(cmtRecord) + ' ' + %trim(TxLine);
                           if %scan('-->':cmtRecord:1) > 0;
                              if objType=*blanks and
                                 %scan('Created':cmtRecord:1) > 0;
                                 position = %scan('<!--':cmtRecord:1);
                                 position = position + 4;
                                 if %scan('-->':cmtRecord:position) > 1;
                                    endpos = %scan('-->':cmtRecord:position);
                                    objType = %subst(cmtRecord:position:
                                                endpos-position);
                                    // replace special chars with blanks
                                    objType = %xlate( fromcc: to : objType);
                                    objType = %xlate( fromlf: to : objType);
                                    objType = %xlate( fromboth: to : objType);
                                 endif;
                                 leave;
                              endif;
                           endif;
                        enddo;
                     endif;
                  endif;

                  // retrieve desired information
                  // first get Object Title from MRC Title
                  if objTitle=*blanks and %scan('<title>':TxLine:1) > 0;
                     position = %scan('<title>':TxLine:1);
                     if %scan('</title>':TxLine:position+6) > 1;
                        endpos=%scan('</title>':TxLine:position+6);
                        objTitle = %subst(TxLine:position+7:
                                   endpos - position - 7);
                     endif;
                  endif;

                  // if the Bfc Version is found populate Version
                  if objVersion=*blanks and (%scan('bfcVersion':TxLine:1) > 0
                           or %scan('bfcversion':TxLine:1) > 0
                           or %scan('bfc_Version':TxLine:1) > 0
                           or %scan('bfc_version':TxLine:1) > 0);
                     select;
                       when %scan('bfcVersion':TxLine:1) > 0;
                         position = %scan('bfcVersion':TxLine:1);
                       when %scan('bfcversion':TxLine:1) > 0;
                         position = %scan('bfcversion':TxLine:1);
                       when %scan('bfc_Version':TxLine:1) > 0;
                         position = %scan('bfc_Version':TxLine:1);
                       when %scan('bfc_version':TxLine:1) > 0;
                         position = %scan('bfc_version':TxLine:1);
                     endsl;
                     if %scan('"':TxLine:position) > 1;
                        position = %scan('"':TxLine:position);
                        if %scan('"':TxLine:position+1) > 1;
                           endpos=%scan('"':TxLine:position+1);
                       objVersion = %subst(TxLine:position+1:endpos-position-1);
                        endif;
                     endif;
                  endif;

                  // if the Bfc Title is found use it instead of MRC Title
                  if (%scan('bfcTitle':TxLine:1) > 0
                           or %scan('bfctitle':TxLine:1) > 0
                           or %scan('bfc_Title':TxLine:1) > 0
                           or %scan('bfc_title':TxLine:1) > 0);
                     select;
                       when %scan('bfcTitle':TxLine:1) > 0;
                         position = %scan('bfcTitle':TxLine:1);
                       when %scan('bfctitle':TxLine:1) > 0;
                         position = %scan('bfctitle':TxLine:1);
                       when %scan('bfc_Title':TxLine:1) > 0;
                         position = %scan('bfc_Title':TxLine:1);
                       when %scan('bfc_title':TxLine:1) > 0;
                         position = %scan('bfc_title':TxLine:1);
                     endsl;
                     if %scan('"':TxLine:position) > 1;
                        position = %scan('"':TxLine:position);
                        if %scan('"':TxLine:position+1) > 1;
                           endpos=%scan('"':TxLine:position+1);
                         objTitle = %subst(TxLine:position+1:endpos-position-1);
                           // leave;
                        endif;
                     endif;
                  endif;

                  // Look for Jquery method calls
                  select;
                    when %scan('jQuery.':txLine:1) > 0;
                       if %scan('(':txLine:1) >0;
                          position = %scan('jQuery.':txLine:1);
                          endpos = %scan('(':txLine:position);
                          wkjQuery = %subst(txLine:position+7:
                                     (endpos)-(position+7));
                          if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                             if objjQuery=*blanks;
                                objjQuery = wkjQuery;
                             else;
                                objjQuery = %trim(objjQuery) + ',' +
                                            %trim(wkjQuery);
                             endif;
                          endif;
                       endif;
                    when %scan('jQuery(':txLine:1) > 0;
                       // jQuery('#trythis').show();
                       position = %scan('jQuery(':txLine:1);
                       if %scan(').':txLine:position+6) > 0;
                          position = %scan(').':txLine:position+6);
                          if %scan('(':txLine:position) > 0;
                             endpos = %scan('(':txLine:position+1);
                             wkjQuery = %subst(txLine:position+2:
                                        (endpos) - (position+2));
                             if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                                if objjQuery=*blanks;
                                   objjQuery = wkjQuery;
                                else;
                                   objjQuery = %trim(objjQuery) + ',' +
                                               %trim(wkjQuery);
                                endif;
                             endif;
                          endif;
                       endif;
                    when %scan('.':txLine:1) > 0;
                       // .success(function()......
                       position = %scan('.':txLine:1);
                       if %scan('(function()':txLine:position)>0;
                          endpos = %scan('(function()':txLine:position);
                          if (endpos - position) <= 10;
                             wkjQuery = %subst(txLine:position+1:
                                        (endpos) - (position+1));
                             if %scan(%trim(wkjQuery):objjQuery:1) = 0;
                                if objjQuery=*blanks;
                                   objjQuery = wkjQuery;
                                else;
                                   objjQuery = %trim(objjQuery) + ',' +
                                               %trim(wkjQuery);
                                endif;
                             endif;
                          endif;
                       endif;
                  endsl;

                  // Look for Java method calls
                  select;
                    when %scan('.':txLine:1) > 0 and %scan('jQuery':txLine:1)=0;
                       // selWo.trim()   would trim field selWo
                       position = %scan('.':txLine:1);
                       if %scan('()':txLine:position) >0 and
                          (%scan('()':txLine:position)-position) <=8;
                          endpos = %scan('()':txLine:position);
                          wkjava = %trim(%subst(txLine:position+1:
                                     (endpos)-(position+1))) + '()';
                          if %scan(%trim(wkjava):objjava:1) = 0;
                             if objjava=*blanks;
                                objjava = wkjava;
                             else;
                                objjava = %trim(objjava) + ',' +
                                            %trim(wkjava);
                             endif;
                          endif;
                       endif;
                  endsl;

710bA             // Look for session Storage Variables
710bA             select;
710bA               // sessisonStorage.setItem('Mutiday');
710bA               when %scan('sessionStorage':txLine:1) > 0
710bA                    and (%scan('setItem':txLine:1) > 0 or
710bA                         %scan('getItem':txLine:1) > 0 or
710bA                         %scan('removeItem':txLine:1) > 0 or
710bA                         %scan('popArrayItem':txLine:1) > 0 or
710bA                         %scan('pushArrayItem':txLine:1)> 0);
710bA                  position = %scan('sessionStorage':txLine:1);
710bA                  if %scan('(':txLine:position) >0;
710bA                     position = %scan('(':txLine:position);
710bA                     pos1 = %scan(sq:txLine:position+2);
710bA                     pos2 = %scan('"':txLine:position+2);
710bA                     endpos=pos1;
710bA                     if pos2>*zeros and pos2<endpos;
710bA                        endpos=pos2;
710bA                     endif;
710bA                     if endpos<>0 and %subst(txLine:position-6:6)
710bA                             <>'jQuery';
710bA                        wksessvar = %trim(%subst(txLine:position+2:
710bA                                   (endpos)-(position+2)));
710bA                        if wksessvar <> *blanks;
710bA                           if %scan(%trim(wksessvar):objsessvar:1) = 0;
710bA                              if objsessvar=*blanks;
710bA                                 objsessvar = wksessvar;
710bA                              else;
710bA                                 objsessvar = %trim(objsessvar) + ',' +
710bA                                             %trim(wksessvar);
710bA                              endif;
710bA                           endif;
710bA                        endif;
710bA                     endif;
710bA                  endif;
710bA               when %scan('sessionStorage':txLine:1) > 0;
710bA                  // sessisonStorage.pItem  where the variable is like method
710bA                  position = %scan('sessionStorage':txLine:1);
710bA                  if %subst(txLine:position+14:1) = '.';
710bA                     position = %scan('.':txLine:position);
710bA                     pos1 = %scan(')':txLine:position);
710bA                     pos2 = %scan(' ':txLine:position);
710bA                     pos3 = %scan(';':txLine:position);
710bA                     pos4 = %scan('=':txLine:position);
710bA                     pos5 = %scan('"':txLine:position);
710bA                     endpos=pos1;
710bA                     if pos2>*zeros and pos2<endpos;
710bA                        endpos=pos2;
710bA                     endif;
710bA                     if pos3>*zeros and pos3<endpos;
710bA                        endpos=pos3;
710bA                     endif;
710bA                     if pos4>*zeros and pos4<endpos;
710bA                        endpos=pos4;
710bA                     endif;
710bA                     if pos5>*zeros and pos5<endpos;
710bA                        endpos=pos5;
710bA                     endif;
710bA                     if endpos<>0;
710bA                        wksessvar = %trim(%subst(txLine:position+1:
710bA                                   (endpos)-(position+1)));
710bA                        if wksessvar <> *blanks;
710bA                           if %scan(%trim(wksessvar):objsessvar:1) = 0;
710bA                              if objsessvar=*blanks;
710bA                                 objsessvar = wksessvar;
710bA                              else;
710bA                                 objsessvar = %trim(objsessvar) + ',' +
710bA                                             %trim(wksessvar);
710bA                              endif;
710bA                           endif;
710bA                        endif;
710bA                     endif;
710bA                  endif;
                  endsl;

                  // Look for Javascript and Html program calls/transfers
                  // search each line for BFCDAKOTA and the BFCREPORTS
                  // Loop until all occurences are found and processed
                  position = 1;
                  // BFCDAKOTA.
                  dow 1=1;
                     if %scan('BFCDAKOTA.':TxLine:position) > 0;
                        position = %scan('BFCDAKOTA.':TxLine:position);
                        if %subst(TxLine:position+10:1) = 'I' or
                           %subst(TxLine:position+10:1) = 'M' or
                           %subst(TxLine:position+10:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+11);
                           if (endpos - (position+11) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:9);
                              fcpgm = %subst(TxLine:position+10:endpos-position
                                                   -10);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCDAKOTA is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  // BFCDAKOTA_
                  position = 1;
                  dow 1=1;
                     if %scan('BFCDAKOTA_':TxLine:position) > 0;
                        position = %scan('BFCDAKOTA_':TxLine:position);
                        if %subst(TxLine:position+10:1) = 'I' or
                           %subst(TxLine:position+10:1) = 'M' or
                           %subst(TxLine:position+10:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+11);
                           if (endpos - (position+11) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:9);
                              fcpgm = %subst(TxLine:position+10:endpos-position
                                                   -10);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCDAKOTA is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  position = 1;
                  // BFCREPORTS.
                  dow 1=1;
                     if %scan('BFCREPORTS.':TxLine:position) > 0;
                        position = %scan('BFCREPORTS.':TxLine:position);
                        if %subst(TxLine:position+11:1) = 'I' or
                           %subst(TxLine:position+11:1) = 'M' or
                           %subst(TxLine:position+11:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+12);
                           if (endpos - (position+12) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:10);
                              fcpgm = %subst(TxLine:position+11:endpos-position
                                                   -11);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCREPORTS is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;

                  position = 1;
                  // BFCREPORTS_
                  dow 1=1;
                     if %scan('BFCREPORTS_':TxLine:position) > 0;
                        position = %scan('BFCREPORTS_':TxLine:position);
                        if %subst(TxLine:position+11:1) = 'I' or
                           %subst(TxLine:position+11:1) = 'M' or
                           %subst(TxLine:position+11:1) = 'R';
                           endpos=%check('0123456789':TxLine:position+12);
                           if (endpos - (position+12) ) > 2;
                              fciid=%subst(verName:1:20);
                              fcdict = %subst(TxLine:position:10);
                              fcpgm = %subst(TxLine:position+11:endpos-position
                                                   -11);
                              if fciid <> %trim(fcdict) + '.' + %trim(fcpgm);
                                 write fcrec;
                              endif;
                           endif;
                        endif;
                     else;
                        // if BFCREPORTS is not found then leave dou 1=1;
                        leave;
                     endif;
                     position = position + 10;
                  enddo;
      /end-free
     c     skipmhtmlrd   tag
      /free
                  read textfile;
               enddo;

            Close textfile;
            @command = 'DLTOVR FILE(TEXTFILE)';
            returnCode = goCmd(%trim(@command));

            endsr;
      /end-free

      /free
        // ---------------------------------------------------- //
        // -- readJava - Read the Java file to update certain   //
        //    fields when not found in Html file                //
        // ---------------------------------------------------- //
         begsr readJava;


              // clear flat text file and append this html to flat file
              @command = 'CLRPFM FILE(QTEMP/TEXTFILE)';
              returnCode = goCmd(%trim(@command));

              position = %scan('HTML':drnam:1);
              drnamj = drnam;
              %subst(drnamj:position:4)='JAVA';
              Pathfile = %trim(pathToList) + '/' + %trim(drnamj);

              dlmtor = '*LF';
              dow 1 =1;
                 // create flatfile from java file using Carriage Return
                 // as delimiter first.  If that only returns one record
                 // meaning it must have been using Line Feed as the
                 // delimiter then change to *LF and try it
                 @command = 'CPYFRMIMPF FROMSTMF(' + sq +
                             %trim(PathFile) + sq + ') ' +
                            'TOFILE(QTEMP/TEXTFILE) RCDDLM(' +
                            %trim(dlmtor) + ') ' +
                            'RPLNULLVAL(*FLDDFT) FLDDLM(|)';
                 returnCode = GoCmd(%trim(@command));
                 exec sql select count(*) into :reccnt from qtemp/textfile;
                 if (sqlStt = '00000' and reccnt>20)
                      or dlmtor='*CR';
                    leave;
                 endif;
                 dlmtor='*CR';
              enddo;
710bA
710bA         // get file date from Java file as last compile date
710bA         monitor;
710bA            rtnVal = stat( %trim(PATHFILE) :
                          %addr(mystat) ) ;
710bA            p_statds = %addr(mystat);
710bA            exsr convertdate;
710bA         on-error;
710bA            // if Java file not found then use HTML file date
710bA            monitor;
710bA               Pathfile = %trim(pathToList) + '/' + %trim(drnam);
710bA               rtnVal = stat( %trim(PATHFILE) :
710bA                        %addr(mystat) ) ;
710bA               p_statds = %addr(mystat);
710bA               exsr convertdate;
710bA            on-error;
710bA               // if neither are found use 1-1-2010
710bA               crtDate = z'2010-01-01-00.00.00';
710bA            endmon;
710bA         endmon;

              // now that the html file is easily readable simply
              // loop through looking for tags of information

               if not %open(textfile);
                  @command = 'OVRDBF FILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE)';
                  returnCode = goCmd(%trim(@command));
                  open textfile;
               endif;
               read textfile;

               // only read first record of Java file to get Type when not
               // in Html file
710bD    //      if objType=*blanks and
710bM          if %scan('Created':TxLine:1) > 0 and %scan('//':TxLine:1)>0;
                  position = %scan('//':TxLine:1);
                  endpos = %scan('//':TxLine:position+3);
                  if endpos > 0;
                     objType = %subst(TxLine:position+2:
                                (endpos) - (position+2));
                  else;
                     endpos=250;
                     objType = %trim(%subst(TxLine:position+2:
                                (endpos) - (position+2)));
                  endif;
               endif;

               objproc=*blanks;
               objFiles=*blanks;
               objFunc=*blanks;
               objFields=*blanks;
               wkproc=*blanks;
               wkloc=*blanks;
               wkfieldName=*blanks;
               foundFields = *off;
               foundFileFlds = *off;
               // now look through remainder of Java file to locate
               // any procedure calls and location
               dow not %eof(textfile);
                  // get Procedure called and Location called from
                  if %scan('//call object':TxLine:1)>0 or
                     %scan('//call(':TxLine:1)>0;
                     select;
                       when %scan('//call object':TxLine:1)>0;
                         position = %scan('object':txLine:1);
                         endpos = %scan(' ':txLine:position+8);
                         wkProc = %subst(txLine:position + 8:endpos-position-8);
                         position = %scan('*':txLine:endpos);
                         endpos = %scan(' ':txLine:position);
                       when %scan('//call(':TxLine:1)>0;
                         position = %scan('//call(':txLine:1);
                         endpos = %scan(')':txLine:position+7);
                         wkProc = %subst(txLine:position + 7:endpos-position-7);
                         position = %scan('*':txLine:endpos);
                         endpos = %scan(' ':txLine:position);
                     endsl;
                     if endpos=0;
                        endpos=2048;
                     endif;
                     wkloc = %subst(txLine:position:endpos-position+1);
                     wkproc = %xlate(lowercase:uppercase:wkProc);
                     wkloc = %xlate(lowercase:uppercase:wkLoc);
710bA                @command = 'CHKOBJ OBJ(' +
710bA                            %trim(wkproc) + ') OBJTYPE(*PGM)';
710bA                returnCode = goCmd(%trim(@command));
710bA                if returncode = 0;
710bA                   if objproc = *blanks;
710bA                      objproc = %trim(wkloc) + '.' + %trim(wkproc) + '(i)';
710bA                   else;
710bA                      if %scan(%trim(wkloc) + '.' + %trim(wkproc)
710bA                               :objProc:1)=0;
710bA                         objproc = %trim(objproc) + ',' + %trim(wkloc) +
710bA                                    '.' + %trim(wkproc) + '(i)';
710bA                      endif;
710bA                   endif;
710bA                else;
710bA                   // if not found on iSeries add without (i)
710bA                   if objproc = *blanks;
710bA                      objproc = %trim(wkloc) + '.' + %trim(wkproc);
710bA                   else;
710bA                      if %scan(%trim(wkloc) + '.' + %trim(wkproc)
710bA                               :objProc:1)=0;
710bA                         objproc = %trim(objproc) + ',' + %trim(wkloc) +
710bA                                    '.' + %trim(wkproc);
710bA                      endif;
                        endif;
                     endif;
                  endif;

                  // get CALCULA field names used in object along with assigned name
                  // not able to always get correct name with inconsisent method in java file
                  select;
                     when dict='BFCDAKOTA.';
                        if not foundfields;
                           dow not %eof(textfile);
                              if %scan('String CALCULA':TxLine:1) > 0 or
                                 %scan('Double CALCULA':TxLine:1) > 0;
                                 position = %scan('String CALCULA':TxLine:1);
                                 if position = 0;
                                    position = %scan('Double CALCULA':TxLine:1);
                                 endif;
                                 wkFieldName = %subst(TxLine:position+7:10);
710bA                            if %scan(%trim(wkFieldName):objFields:1)=0;
710bA                               position = %scan('//':TxLine:position+2);
710bA                               endpos = %scan(' ':TxLine:position+1);
710bA                               wkFieldName = %trim(wkFieldName) + '(' +
710bA                                   %trim(%subst(TxLine:position+2:
710bA                                          endpos-(position+2))) + ')';
710bA                               foundfields=*on;
710bA                               if objFields = *blanks;
710bA                                  objFields = %trim(wkFieldName);
710bA                               else;
710bA                                  objFields = %trim(objFields) + ',' +
710bA                                               %trim(wkFieldName);
710bA                               endif;
710bA                            endif;
                              else;
                                 leave;
                              endif;
                              read textfile;
                           enddo;
                        endif;
                  endsl;

                  // get File field names used in object along with assigned name
                  select;
                     when dict='BFCDAKOTA.';
                        if not foundFileflds and
                           %scan('private String rls_':TxLine:1) > 0;
                           dow not %eof(textfile);
                              if %scan('private String rls_':TxLine:1) > 0 and
                                 %scan('CALCULA':TxLine:1) =0;
                               position = %scan('private String rls_':TxLine:1);
                               endpos = %scan('=':TxLine:position+19);
                               if endpos>position;
                                  wkFieldName = %subst(TxLine:position+19:
                                                (endpos-1)-(position+19));
                                  foundFileflds=*on;
                                  if objFields = *blanks;
                                     objFields = %trim(wkFieldName);
                                  else;
                                     objFields = %trim(objFields) + ',' +
                                                  %trim(wkFieldName);
                                  endif;
                               endif;
                              else;
                                 // if val instead of rls string then stay in loop
                                 // and read next record.  If neither rls or val
                                 // then leave loop meaning all fields from files
                                 // have been accounted for.
                                 if %scan('private String val_':TxLine:1) > 0 or
                                    %scan('CALCULA':TxLine:1) >0;
                                 else;
                                    leave;
                                 endif;
                              endif;
                              read textfile;
                           enddo;
                        endif;
                  endsl;

                  // get functions called via Calculations
                  if %scan('fld.setCalc("","':TxLine:1)>0;
                     position = %scan('fld.setCalc("","':txLine:1);
                     dow not %eof(textFile);
                        // loop looking for all Files used. Once
                        // we reach sqlFile we have found all functions
                        if %scan('sqlFile':TxLine:1)>0;
                           leave;
                        endif;
                        if %scan('fld.setCalc("","':TxLine:1)>0;
                           position = %scan('fld.setCalc("","':txLine:1);
                           position = position + 16;
                           endpos = %scan('(':txLine:position);
                           if endpos<>*zeros;
                              // make sure this is valid function
                              wrkFunc = %subst(txLine:position:
                                               endpos-position);
                              @command = 'CHKOBJ OBJ(' +
                                         %trim(wrkFunc) + ') OBJTYPE(*PGM)';
                              returnCode = goCmd(%trim(@command));
                              if returncode = 0;
                                 wrkFunc = %xlate(lowercase:uppercase:wrkFunc);
                                 if objFunc = *blanks;
                                    objFunc = %trim(wrkFunc) + '(i)';
                                 else;
                                    if %scan(wrkFunc:objFunc:1)=0;
                                       objFunc = %trim(objFunc) + ',' +
                                                  %trim(wrkFunc) + '(i)';
                                    endif;
                                 endif;
710bA                         else;
710bA                            // if not found on iSeries add without (i)
710bA                            if objFunc = *blanks;
710bA                               objFunc = %trim(wrkFunc);
710bA                            else;
710bA                               if %scan(wrkFunc:objFunc:1)=0;
710bA                                  objFunc = %trim(objFunc) + ',' +
710bA                                             %trim(wrkFunc);
710bA                               endif;
710bA                            endif;
                              endif;
                           endif;
                        endif;
                        read textfile;
                     enddo;
                  endif;

                  // get files used
                  if %scan('String sqlFile':TxLine:1)>0;
                     position = %scan('String sqlFile':txLine:1);
                     dow not %eof(textFile);
                        // loop looking for all Files used. Once
                        // we reach sqljoins or sqlwhere we have
                        // seen all files and should exit
                        if (%scan('sqlJoins':TxLine:1)>0 or
                           %scan('sqlWhere':TxLine:1)>0) and
                           %scan('F.':TxLine:1)=0;
                           leave;
                        endif;
                        position=1;
                        dou 1<>1;
                           if (%scan('F.':TxLine:position)>0 and
                                %scan(' T':TxLine:position)>0) or
                              (%scan('SYS.':TxLine:position)>0 and
                                %scan(' T':TxLine:position)>0);
                              if %scan('SYS.':TxLine:position)>0;
                                 position = %scan('SYS.':txLine:position);
                                 endpos = %scan(' T':txLine:position+4);
                                 wrkFile = %subst(txLine:position+4:
                                                endpos-position-4);
                              else;
                                 position = %scan('F.':txLine:position);
                                 endpos = %scan(' T':txLine:position+2);
                                 wrkFile = %subst(txLine:position+2:
                                                endpos-position-2);
                              endif;

                              if objFiles = *blanks;
                                 objFiles = %trim(wrkFile) + ',';
                              else;
                                 objFiles = %trim(objFiles) +
                                               %trim(wrkFile) + ',';
                              endif;
                           else;
                              leave;
                           endif;
                           position=endpos;
                        enddo;
                        position=1;
                        read textfile;
                     enddo;
                  endif;

                  // since Files come after Procedure as soon as objFiles
                  // is not blank we should leave to prevent more reads
                  // than necessary
                  if objFiles<>*blanks;
                     leave;
                  endif;

                  read textfile;
               enddo;

               Close textfile;
               @command = 'DLTOVR FILE(TEXTFILE)';
               returnCode = goCmd(%trim(@command));

            endsr;
      /end-free

      /free
        // ---------------------------------------------------- //
        // -- readXml - Read the XML file to update certain     //
        // ---------------------------------------------------- //
         begsr readXml;


              // clear flat text file and append this html to flat file
              @command = 'CLRPFM FILE(QTEMP/TEXTFILE)';
              returnCode = goCmd(%trim(@command));

              position = %scan('S.HTML':drnam:1);
              drnamj = drnam;
              %subst(drnamj:position:6)='P.XML ';
              Pathfile = %trim(pathToList) + '/' + %trim(drnamj);

              dlmtor = '*LF';
              dow 1 =1;
                 // create flatfile from java file using Carriage Return
                 // as delimiter first.  If that only returns one record
                 // meaning it must have been using Line Feed as the
                 // delimiter then change to *LF and try it
                 @command = 'CPYFRMIMPF FROMSTMF(' + sq +
                             %trim(PathFile) + sq + ') ' +
                            'TOFILE(QTEMP/TEXTFILE) RCDDLM(' +
                            %trim(dlmtor) + ') ' +
                            'RPLNULLVAL(*FLDDFT) FLDDLM(|)';
                 returnCode = GoCmd(%trim(@command));
                 exec sql select count(*) into :reccnt from qtemp/textfile;
                 if (sqlStt = '00000' and reccnt>20)
                      or dlmtor='*CR';
                    leave;
                 endif;
                 dlmtor='*CR';
              enddo;

              // now that the html file is easily readable simply
              // loop through looking for tags of information

               if not %open(textfile);
                  @command = 'OVRDBF FILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE)';
                  returnCode = goCmd(%trim(@command));
                  open textfile;
               endif;
               objUpdMRC=*blanks;
               read textfile;

               // look for setting to determine if this objects updates files
               // or whether files are updated outside MRC
               dow not %eof(textfile);
                  if objUpdMrc=*blanks and
                     (%scan('skip_db_actions':TxLine:1) > 0 or
                      %scan('skip_update':TxLine:1) > 0);
                     position = %scan('db_actions':TxLine:1);
                     if position = 0;
                        position = %scan('skip_update':TxLine:1);
                     endif;
                     position = %scan('e="':TxLine:position);
                     objUpdMrc = %subst(TxLine:position+3:1);
                     if objUpdMrc = '1';
                        objUpdMrc = 'BFC';
                     else;
                        objUpdMrc = 'MRC';
                     endif;
                     leave;
                  endif;
                  read textfile;
               enddo;

               // if Skip DB Updates not found in XML set to MRC
               if %subst(drnam:1:1)='M'
                  and objUpdMrc = *blanks;
                  objUpdMrc = 'MRC';
               endif;

               Close textfile;
               @command = 'DLTOVR FILE(TEXTFILE)';
               returnCode = goCmd(%trim(@command));

            endsr;
      /end-free

      /free
        // ---------------------------------------------------- //
        // -- readXmlRpts - Read the XML file specifically for  //
        //    Reports                                           //
        // ---------------------------------------------------- //
         begsr readXmlRpts;


              // only execute for reports.  File not there for screens
              if dict <> 'BFCREPORTS.';
                 leavesr;
              endif;

              // clear flat text file and append this html to flat file
              @command = 'CLRPFM FILE(QTEMP/TEXTFILE)';
              returnCode = goCmd(%trim(@command));

              position = %scan('S.HTML':drnam:1);
              drnamj = drnam;
              %subst(drnamj:position:6)='.XML  ';
              Pathfile = %trim(pathToList) + '/' + %trim(drnamj);

              dlmtor = '*LF';
              dow 1 =1;
                 // create flatfile from java file using Carriage Return
                 // as delimiter first.  If that only returns one record
                 // meaning it must have been using Line Feed as the
                 // delimiter then change to *LF and try it
                 @command = 'CPYFRMIMPF FROMSTMF(' + sq +
                             %trim(PathFile) + sq + ') ' +
                            'TOFILE(QTEMP/TEXTFILE) RCDDLM(' +
                            %trim(dlmtor) + ') ' +
                            'RPLNULLVAL(*FLDDFT) FLDDLM(|)';
                 returnCode = GoCmd(%trim(@command));
                 exec sql select count(*) into :reccnt from qtemp/textfile;
                 if (sqlStt = '00000' and reccnt>20)
                      or dlmtor='*CR';
                    leave;
                 endif;
                 dlmtor='*CR';
              enddo;

              // now that the html file is easily readable simply
              // loop through looking for tags of information

               if not %open(textfile);
                  @command = 'OVRDBF FILE(TEXTFILE) TOFILE(QTEMP/TEXTFILE)';
                  returnCode = goCmd(%trim(@command));
                  open textfile;
               endif;
               read textfile;

               // find fields used on reports
               dow not %eof(textfile);
710bA
710bA             // when we hit field descriptions tag we
710bA             // should fo inter loop to load all the
710bA             // field descriptions in array for processing
710bA             // when calcula field found to associate name
710bA             if %scan('<fielddescription>':TxLine:1)>0;
710bA                read textfile;
710bA                clear fldary;
710bA                dow not %eof(textfile);
710bA                   // when end field description tag reached leave
710bA                   if %scan('</fielddescription>':txLine:1) > 0;
710bA                      read textfile;
710bA                      leave;
710bA                   endif;
710bA                   // substring out field name and load in array
710bA                   if %scan('<F':txLine:1)>0;
710bA                      position = %scan('<F':txLine:1);
710bA                      endpos = %scan('>':txLine:position);
710bA                      fldnum = %dec(%subst(txLine:position+2:
710bA                                    endpos - (position+2)):3:0);
710bA                      position = endpos;
710bA                      endpos = %scan('</F':txLine:position);
710bA                      fldAry(fldnum) = %subst(txLine:position+1:
710bA                                         endpos - (position+1));
710bA                   endif;
710bA                   read textfile;
710bA                enddo;
710bA             endif;
710bA
710bA             if %scan('${row.':TxLine:1) > 0 and
710bA                %scan('<F':txLine:1) > 0;
                     position = %scan('${row.':TxLine:1);
                     if %scan('?':txLine:position + 3) > 0 or
                        %scan('}':txLine:position + 3) > 0;
                        endpos = %scan('?':txLine:position + 3);
                        if endpos =0;
                           endpos = %scan('}':txLine:position + 3);
                        endif;
                        wkfieldName = %subst(txLine:position + 6:
                                  (endpos) - (position +6));
710bA                   // now get array number associated to field
710bA                   // description array above for calcula to
710bA                   // append to this for reference
710bA                   position=%scan('<F':txLine:1);
710bA                   endpos = %scan('>':txLine:position);
710bA                   fldnum = %dec(%subst(txLine:position+2:
710bA                                  endpos - (position+2)):3:0);
710bA                   fldnum = fldnum + 1;
710bA                   // if calcula field include program field desc
710bA                   if %scan('CALCULA':wkfieldname:1) > 0;
710bA                      wkfieldname = %trim(wkfieldname) + '(' +
710bA                                    %trim(fldary(fldnum)) + ')';
710bA                   endif;
                        if %scan(%trim(wkFieldName):objFields:1)=0;
                           if objFields = *blanks;
                              objFields = wkFieldName;
                           else;
                              objFields = %trim(objFields) + ',' +
                                        %trim(wkFieldName);
                           endif;
                        endif;
                     endif;
                  endif;
                  read textfile;
               enddo;

               Close textfile;
               @command = 'DLTOVR FILE(TEXTFILE)';
               returnCode = goCmd(%trim(@command));

            endsr;
      /end-free

      * Retrieve the error number for UNIX-type APIs

     P errno           b
     D errno           pi            10i 0
     D p_errno         s               *
     D wwreturn        s             10i 0 based( p_errno )
     C                   eval      p_errno = @__errno
     c                   return    wwreturn
     P                 e
710bA
710bA * Convert Unix date to Rpg readable date
710bAP UnixToRpg       B
710bAD UnixToRpg       PI              Z
710bAD UnixTime                      10U 0 value
710bA
710bAD CEEUTCO         PR                  OPDESC
710bAD Hours                         10I 0
710bAD Mins                          10I 0
710bAD Secs                           8F
710bAD fc                            12A   options(*omit)
710bA
710bAD Epoch           c                   z'1970-01-01-00.00.00'
710bAD offset          s             10I 0 static inz(-1)
710bAD Hours           s             10I 0 static
710bAD Mins            s             10I 0 static
710bAD Secs            s              8F   static
710bAD retval          s               z
710bA
710bA /FREE
710bA  if (offset = -1);
710bA    CEEUTCO(Hours: Mins: Secs: *OMIT);
710bA    offset = secs;
710bA  endif;
710bA
710bA  retval = Epoch
710bA  + %seconds(UnixTime)
710bA  + %seconds(offset)
710bA  - %hours(ucOffset);
710bA  return retval;
710bA /end-free
710bAP                 e

710bA*----------------------------------------------------------------
710bA*  GetCurrStamp  Get current timestamps
710bA*----------------------------------------------------------------
710bA
710bAp GetCurrStamp    b
710bAd GetCurrStamp    pi
710bA
710bA /free
710bA
710bA    getmicrotime(currstampuc:currstampsys);
710bA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
710bA    currstamploc = currstampsys + %hours(bfcoffset);
710bA
710bA /end-free
710bA
710bAp GetCurrStamp    e
