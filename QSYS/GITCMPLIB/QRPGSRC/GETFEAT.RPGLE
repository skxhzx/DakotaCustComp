      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETFEAT   Get Features
     *  11 May 2011
     *  Jeff Jahnke
     *
     *  Revisions
     *
640 A*    05/11/11  JCJ  6.40
     *      - Created.
     *
730aA*    04/02/19  DAS  7.30
     *      - Added optbtype, optbcol
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *    OPLGHT  -  Truck Builder Only - Light/Full code
730aA*    OPTBTYPE - TruckBuilder Type (S=Standard, E-Enhanced/Advanced, B=Both)
730aA*    OPTBCOL - TruckBuilder Columns (N=Std 2 columns, Y=3+ Columns)
     *
     * Data structure
     *
     D opfdta          DS
     D  opfeat                 1      1
     D  oplght                 2      4
730aAD  optbtype               5      5
730aAD  optbcol                6      6
     D  opfend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D optcod          s              8

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd   *GET     - Get feature codes
     *      $pwhse  Warehouse
     *
     *    Return Parameters
     *      $pfeature  Feature code  (1=Inbound, 2=Full, 3=Outbound)
     *      $plight    Truck Builder Light version (Y/N)
730aA*      $ptbtype   TruckBuilder Type (S,E,B)
730aA*      $ptbcol    TruckBuilder Type (Y,N)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $pfeature         1
     C                   parm                    $plight           1
730aAC                   parm                    $ptbtype          1
730aAC                   parm                    $ptbcol           1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *   Get *FEATURE options.

     C                   eval      optcod = '*FEATURE'
     C     keyop         chain     options
     C                   if        not %found(options)
     C                   eval      opfeat = '0'
     C                   eval      oplght = ' '
730aAC                   if        %parms >= 5
730aAC                   eval      optbtype = ''
730aAC                   endif
730aAC                   if        %parms >= 6
730aAC                   eval      optbcol = ''
730aAC                   endif
     C                   else
     C                   eval      opfdta = opdata
     C                   endif

     C                   eval      $pfeature = opfeat
     C                   eval      $plight = 'N'

     *   See if Truck Builder (Outbound) is the 'Light' version.
     *   Code 'E6b' identifies the Full version of Truck Builder.
     *   Any other code indicates the Light version.

     C                   if        opfeat = '3'
     C                             and oplght <> 'E6b'
     C                   eval      $plight = 'Y'
     C                   endif

730aAC                   if        %parms >= 5
730aAC                   if        optbtype <> 'S'
730aAC                             and optbtype <> 'E'
730aAC                             and optbtype <> 'B'
730aAC                   eval      $ptbtype = 'S'
730aAC                   else
730aAC                   eval      $ptbtype = optbtype
730aAC                   endif
730aAC                   endif

730aAC                   if        %parms >= 6
730aAC                   if        optbcol <> 'N'
730aAC                             and optbcol <> 'Y'
730aAC                   eval      $ptbcol = 'N'
730aAC                   else
730aAC                   eval      $ptbcol = optbcol
730aAC                   endif
730aAC                   endif

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    optcod

     C                   endsr
