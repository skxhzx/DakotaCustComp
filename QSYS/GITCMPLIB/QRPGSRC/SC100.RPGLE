     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SC100     Print test page for Toledo Scale Station
     *  26 February 2014
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  02/26/14  KDE  6.50
     *    - Created.
700 A*  11/02/15  KDE  7.00
     *    - mod to print zpl instead of plain text for laser
710 A*  07/12/17  KDE  7.10
     *    - Recompile because file Scale changed
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

700 Afqsysprt   o    f  132        printer usropn

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s            200
     D pReturn         s             10
     D cmd             s           3000    varying

     d rDate           s              8    inz('02/01/14')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Station ID
     *
     *    Returned Parameters
     *      -None -
     *
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *
     *----------------------------------------------------------------     ****
     C     *entry        plist
     C                   parm                    $pStation        10

      /free

         rdate = %char(%date():*mdy/);
700 A    open qsysprt;

700 A     except detail;
700 A     close qsysprt;

         *inlr = *on;

      /end-free

700 AOqsysprt   e            detail         1
700 AO                                              '^XA'
700 AO          e            detail         1
700 AO                                              '^LH30,30'
700 AO          e            detail         1
700 AO                                              '^FO20,10^AD^FD********^FS'
700 AO          e            detail         1
700 AO                                              '^FO20,70^AD^FDZEBRA^FS'
700 AO          e            detail         1
700 AO                                              '^FO20,130^AD^FDTEST^FS'
700 AO          e            detail         1
700 AO                                              '^FO20,190^AD^FDBFC PROD^FS'
700 AO          e            detail         1
700 AO                                              '^FO20,250^AD^FD********^FS'
700 AO          e            detail         1
700 AO                                              '^XZ'
     *
     *  COMPILE TIME TABLES
     *
