      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSDIRPUR  Archive/Purge IFS Directories
     *  01 May 2019
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    05/01/19  KDE  7.30
     *      - Created
730aA*    05/07/19  KDE  7.30a
     *      - Multiple includes not finding files.  Had to change syntax
740 A*    03/23/20  KDE  7.40
     *      - Add monitor when archive not choosen.  Causing substring error
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fifspurdir if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d cmdString       s            500
     D forevr          s               n
710 Ad splitAry        s          10000    dim(200)
     d lpos            s              5  0
730aAd arcExisted      s               n
     d recExist        s               n
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3
     D  iWhse          s              3  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D NoSuchPath      C                   'CPE3025'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

710 A***    Used to Split delimited values into an Array   ***
710 Ad Split           pr            50    dim(50)
710 AD  strToSplit                 1000    const
710 AD  delimiter                     3    const

710 A***    Used to Perform Move and Delete action on IFS
710 Ad deleteIFS       pr

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        // Convert warehouse parm into number

        monitor;
          iWhse = %dec(pWhse:3:0);
        on-error;
          return;
        endmon;

        // open file with soft coded IFS directories for purging
        if not %open(ifspurdir);
          open(e) ifspurdir;
          if %error;
            // if file not defined then call old process and return
      /end-free
     c                   call      'IFSTOMCLN'
     c                   parm      ' '           iPath            10
      /free
            *inlr=*on;
            return;
          endif;
        endif;

        // read and process each purge record for IFS

        recExist = *off;
        setll *loval ifspurdir;
        dow forever = forever;
           read ifspurdir;
           if %eof(ifspurdir);
              leave;
           endif;
           if ifwhse<>iWhse;
              iter;
           endif;
           deleteIFS();
           recExist=*on;
        enddo;

        // if no records were defined in ifspurdir then
        // call old IFS cleanup process
        if not recExist;
      /end-free
     c                   call      'IFSTOMCLN'
     c                   parm      ' '           iPath            10
      /free
        endif;

        if %open(ifspurdir);
          close(e) ifspurdir;
          if %error;
            // do nothing if error, just end anyway
          endif;
        endif;

        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  deleteIFS    Delete data from IFS per configuration record read
     *----------------------------------------------------------------

     p deleteIFS       b
     d deleteIFS       pi

     * Local Variables

     D returnField     s             50

      /free

          // remove slashes from the end of the directory strings if present
740 A     monitor;
          if %subst(%trim(ifarcdir):%len(%trim(ifarcdir)):1) = '/'
             or %subst(%trim(ifarcdir):%len(%trim(ifarcdir)):1) = '\';
             ifarcdir = %subst(%trim(ifarcdir):1:%len(%trim(ifarcdir))-1);
          endif;
740 A     on-error;
740 A       ifarcdir=*blanks;
740 A     endmon;
          if %subst(%trim(ifbsedir):%len(%trim(ifbsedir)):1) = '/'
             or %subst(%trim(ifbsedir):%len(%trim(ifbsedir)):1) = '\';
             ifbsedir = %subst(%trim(ifbsedir):1:%len(%trim(ifbsedir))-1);
          endif;
          // if Archive definition exist then Archive move files from active
          // Base directory to Archive directory.
          if %trim(ifarcdir) <> '' and ifarcdys>0;
            // make sure Archive Directory is present and create if not found
            // next Qshell command checks and creates if missing
            cmdString = 'QSH CMD(' + sq + 'test -d ' +
                         %trim(ifarcdir) +
                        ' || mkdir -p ' +
                        %trim(ifarcdir) +
                        sq + ')';
            returnCode = GoCmd(%trim(cmdString));
            if ReturnCode = Success;
              // since directory was confirmed or created perform Archive
              // dtart Qshell command with find of Base Directory
              cmdString = 'QSH CMD(' + sq + 'find ' + %trim(ifbseDir);

              // if Include Sub-Directories is off then add to command
              if ifincldsd <> 'Y';
              cmdString = %trim(cmdString) + '  ! -path ' + %trim(ifbsedir) +
                          ' -prune';
              endif;

730aA         // include field types only
              cmdString = %trim(cmdString) + ' -type f ';

              // split the include files and add each here.
              // if somehow empty then abort and do not take chance
              // on deleting more than desired
              if %trim(ifincldf) = '';
                 return;
              endif;
710 A         splitARy = Split(ifincldf:',');
              lpos=1;
              dow splitAry(lpos) <> *blanks;
730aA            if lpos = 1;
730aA              cmdString = %trim(cmdString) + ' \(';
730aA            else;
730aA              cmdString = %trim(cmdString) + ' -o';
730aA            endif;
                 // add file as entered by user
                 cmdString = %trim(cmdString) + ' -name "' +
                             %trim(splitAry(lpos)) + '"';
                 // add upper case version of file
730aA            cmdString = %trim(cmdString) + ' -o';
                 cmdString = %trim(cmdString) + ' -name "' +
                             %xlate(xlower:xupper:%trim(splitAry(lpos))) + '"';
                 // add lower case version of file
730aA            cmdString = %trim(cmdString) + ' -o';
                 cmdString = %trim(cmdString) + ' -name "' +
                             %xlate(xupper:xlower:%trim(splitAry(lpos))) + '"';
                 lpos = lpos + 1;
              enddo;
              // close the include conditions
              if splitAry(1) <> *blanks;
                cmdString = %trim(cmdString) + ' \)';
              endif;
730aA
              // split the exclude files and add each here.  if empty
              // include nothing
710 A         splitARy = Split(ifexcldf:',');
              lpos=1;
              dow splitAry(lpos) <> *blanks;
730aA            if lpos=1;
730aA              cmdString = %trim(cmdString) + ' ! \(';
730aA            else;
730aA              cmdString = %trim(cmdString) + ' -o';
730aA            endif;
                 // include file as user entered
                 cmdString = %trim(cmdString) + ' -name "' +
                             %trim(splitAry(lpos)) + '"';
                 // include file as lower case
                 cmdString = %trim(cmdString) + ' -o -name "' +
                             %xlate(xupper:xlower:%trim(splitAry(lpos))) + '"';
                 // include file as upper case
                 cmdString = %trim(cmdString) + ' -o -name "' +
                             %xlate(xlower:xupper:%trim(splitAry(lpos))) + '"';
                 // include file with capital first letter and remainder lower case
                 cmdString = %trim(cmdString) + ' -o -name "' +
                             %xlate(xlower:xupper:%subst(
                             %trim(splitAry(lpos)):1:1)) +
                             %xlate(xupper:xlower:%subst(%trim(splitAry(lpos))
                             :2)) + '"';
                 lpos = lpos + 1;
              enddo;
730aA         if splitAry(1) <> *blanks;
730aA            cmdString = %trim(cmdString) + ' \)';
730aA         endif;
730aA
              // Add Archive number of days
              cmdString = %trim(cmdString) + ' -mtime +' + %char(ifarcdys);
              // Put Move command on end of find
              cmdString = %trim(cmdString) + '  -exec mv {} ' +
                          %trim(ifarcdir) + '  \;' + sq + ')';
              returnCode = GoCmd(%trim(cmdString));
            endif;
          endif;

          // if Purge definition exist then Purge from Base Directory
          // User may or may not have Archive setup and Archive could be
          // outside of Base Directory
          if %trim(ifbsedir) <> '' and ifpurdys>0;
             // Purge files

             if %trim(ifarcdir)='' or ifarcdys=0;
               // if no Archive Directory defined then purge from Base Directory
               cmdString = 'QSH CMD(' + sq + 'find ' + %trim(ifbseDir);

               // if Exckude Sub-Directories then add setting to only purge
               // from base directory and go no deeper
               if ifincldsd <> 'Y';
               cmdString = %trim(cmdString) + '  ! -path ' + %trim(ifbsedir) +
                           ' -prune';
               endif;
             else;
               // if Archive Directory defined then purge from Archive since
               // code above would have moved files from active to archive
               cmdString = 'QSH CMD(' + sq + 'find ' + %trim(ifarcDir);

               // if Exckude Sub-Directories then add setting to only purge
               // from Archive directory and go no deeper
               if ifincldsd <> 'Y';
               cmdString = %trim(cmdString) + '  ! -path ' + %trim(ifarcdir) +
                           ' -prune';
               endif;
             endif;

730aA        // include field types only
             cmdString = %trim(cmdString) + ' -type f';

             // split the include files and add each here.
             // if somehow empty then abort and do not take chance
710 A        // on deleting more than desired
             if %trim(ifincldf) = '';
                return;
             endif;
             // split the include files and add each here
710 A        splitARy = Split(ifincldf:',');
             lpos=1;
             dow splitAry(lpos) <> *blanks;
730aA           if lpos = 1;
730aA              cmdString = %trim(cmdString) + ' \(';
730aA           else;
730aA              cmdString = %trim(cmdString) + ' -o';
730aA           endif;
                cmdString = %trim(cmdString) + ' -name "' +
                            %trim(splitAry(lpos)) + '"';
                // add upper case version of file
730aA           cmdString = %trim(cmdString) + ' -o';
                cmdString = %trim(cmdString) + ' -name "' +
                            %xlate(xlower:xupper:%trim(splitAry(lpos))) + '"';
                // add lower case version of file
730aA           cmdString = %trim(cmdString) + ' -o';
                cmdString = %trim(cmdString) + ' -name "' +
                             %xlate(xupper:xlower:%trim(splitAry(lpos))) + '"';
                lpos = lpos + 1;
             enddo;
              // close the include conditions
              if splitAry(1) <> *blanks;
                cmdString = %trim(cmdString) + ' \)';
              endif;
730aA
             // split the exclude files and add each here.  if empty
             // include nothing
710 A        splitARy = Split(ifexcldf:',');
             lpos=1;
             dow splitAry(lpos) <> *blanks;
730aA           if lpos=1;
730aA               cmdString = %trim(cmdString) + ' ! \(';
730aA            else;
730aA              cmdString = %trim(cmdString) + ' -o';
730aA           endif;
                // include file as user entered
                cmdString = %trim(cmdString) + ' -name "' +
                            %trim(splitAry(lpos)) + '"';
                // include file as lower case
                cmdString = %trim(cmdString) + ' -o -name "' +
                            %xlate(xupper:xlower:%trim(splitAry(lpos))) + '"';
                // include file as upper case
                cmdString = %trim(cmdString) + ' -o -name "' +
                            %xlate(xlower:xupper:%trim(splitAry(lpos))) + '"';
                // include file with capital first letter and remainder lower case
                cmdString = %trim(cmdString) + ' -o -name "' +
                            %xlate(xlower:xupper:%subst(
                            %trim(splitAry(lpos)):1:1)) +
                            %xlate(xupper:xlower:%subst(%trim(splitAry(lpos))
                            :2)) + '"';
                lpos = lpos + 1;
             enddo;
730aA        if splitAry(1) <> *blanks;
730aA           cmdString = %trim(cmdString) + ' \)';
730aA        endif;
730aA
             // Add Purge days
             cmdString = %trim(cmdString) + ' -mtime +' + %char(ifpurdys);
             // Put Move command on end of find
             cmdString = %trim(cmdString) + '  -exec rm {} ' +
                         '  \;' + sq + ')';
             returnCode = GoCmd(%trim(cmdString));
          endif;

      /end-free

     p                 e
710 A *
710 A *  Procedure Split..............
710 A *
710 A *  Split Procedure that work like SPLIT in javascript.  It expects an input
710 A *  string up to 1000 characters long, a delimiter 3 character long, and passes
710 A *  back an array with 50 elements 50 character each.  The delmiter could
710 A *  be increased if need be and the code (%len) takes care of it.  You could
710 A *  also change the array size and element count.  If you do you should change
710 A *  split and returnarray here and you procedure definition in main program
710 A *  as well as the array defined in the main program that receives the return
710 A *  from this procedure.  When you return simply loop through array looking for
710 A *  non blanks and do what you need to given your data.
710 A *
710 AP split           b
710 AD split           pi            50    dim(50)
710 AD  data                       1000    const
710 AD  delimiter                     3    const
710 A
710 AD returnArray     s             50    dim(50)
710 A
710 AD startPos        s             10i 0
710 AD foundPos        s             10i 0
710 AD increment       s             10i 0
710 AD index           s              5i 0 inz(1)
710 A /free
710 A  if data <> *blanks;
710 A     increment = %len(%trim(delimiter));
710 A     startPos = 1;
710 A     dou foundPos = %len(data) + 1;
710 A        foundPos = %scan(%trim(delimiter):data:startPos);
710 A        if foundPos = 0;
710 A           foundPos = %len(data) + 1;
710 A        endif;
710 A        returnArray(index) = %subst(data:startPos:foundPos - startPos);
710 A        index += 1;
710 A        startPos = foundPos + increment;
710 A     enddo;
710 A  endif;
710 A
710 A  return returnArray;
710 A /end-free
710 AP split           e
