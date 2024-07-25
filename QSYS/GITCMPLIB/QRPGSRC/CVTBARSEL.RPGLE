      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CVTBARSEL   Convert barcode for combo selection
     *  13 May 2010
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Code
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     Fordp      if   e           k disk

     *------------------------------------------------------------------
     *  Client id's for custom mods.
     *------------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Arrays
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Constants
     *----------------------------------------------------------------

     D Forever         C                   1
     D Numbers         C                   '0123456789'

     *----------------------------------------------------------------
     *   Variables
     *----------------------------------------------------------------

     D ChkNumb         S              3P 0
     D BarChar         S              1
     D BarCodeLen      S              3P 0
     D BarPos          S              3P 0
     D Error           S              1
     D I               S              3P 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *  Input Parameters
     *    $PWhse         Warehouse
     *    $PBarCode      Barcode
     *
     *    Returned Parameters
     *      $PRtid       Route id
     *      $PUnq#       Unique number
     *      $Plbl#       Label number
     *      $PReturn     *OK
     *                   *NOMORE
     *                   *NOTFND
     *                   *INVALID
     *      $PErrMsg     Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *ENTRY        PLIST
     C                   PARM                    $PWhse            3
     C                   PARM                    $PBarCode        15
     C                   PARM                    $PLbl#            7 0
     C                   PARM                    $PRtid            5
     C                   PARM                    $PUnq#            5 0
     C                   PARM                    $PReturn          8
     C                   PARM                    $PErrMsg         60

     C                   eval      $PReturn = '*OK'
     C                   eval      $PErrMsg = ' '
     C                   eval      Error = *OFF
     C                   move      $PWhse        kywhse
     C                   eval      $Plbl# = *zeros
     C                   eval      $PUnq# = *zeros
     C                   eval      $PRtid = *blanks

     *----------------------------------------------------------------
     *  Main Line
     *
     *
     *  Left adjust barcode
     *
     C                   eval      $PBarCode = %TrimL($PBarCode)
     *
     *  Get barcode length
     *
     C                   eval      BarCodeLen = %Len(%Trim($PBarCode))
     *  Verify all characters are numeric
     C                   exsr      BarVfy
     *
     C                   if        Error = *off
     C                   select
     C                   when      BarCodeLen = 10
     C                   exsr      Bar10
     *
     C                   when      BarCodeLen <= 7
     C                   eval      $PLbl# = %dec((%Subst($PBarCode:1:7)):7:0)
     *
     C                   other
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PErrMsg = 'Invalid barcode'
     C                   endsl
     C                   endif
     *
     C                   Return
     *----------------------------------------------------------------
     *           SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine.
     *
     C     *INZSR        begsr

     *  Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc
     *  KLIST

     *
     *  ORDP key list
     C     keyordp       klist
     C                   kfld                    kywhse            3 0
     C                   kfld                    $PRtid
     C                   kfld                    $PUnq#

     C                   endsr
     *----------------------------------------------------------------
     *
     *  BarVfy  Verify barcode is all numeric
     *
     C     BarVfy        begsr
     *
     *  See if we have reached the end of the barcode.
     *
     *  Initialize values.
     *
     C                   eval      BarPos   = 1
     *
     *  Loop through characters looking for numeric value
     *
     C     Forever       DowEq     Forever
     *
     *  Get character
     *
     C                   eval      BarChar = %Subst($PBarCode:BarPos:1)
     *
     *  Character must be numeric.
     *
     C                   eval      ChkNumb = %Scan(BarChar:Numbers)
     C                   if        ChkNumb = 0
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PErrMsg = 'Invalid code found at position '
     C                                        + %Trim(%EditC(BarPos:'Z'))
     C                   leave
     C                   endif
     C                   eval      BarPos  = BarPos + 1
     *
     C                   if        BarPos > BarCodeLen
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C     EndBarVfy     endsr
     *----------------------------------------------------------------
     *
     *  Bar10  - Get value
     *
     C     Bar10         begsr
     *
     *    Get unique number
     *
     C                   eval      $PUnq# = %dec((%Subst($PBarCode:6:5)):5:0)
     *
     *    Get route id
     *
     C                   eval      $PRtid = %Subst($PBarCode:1:5)
     *
     C     keyordp       chain     ordp
     C                   if        %found(ordp)
     C                   eval      $Plbl# = orplbl
     C                   else
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*NOTFND '
     C                   eval      $PErrMsg = 'No label number found '
     C                                        + %Trim($PRtid)
     C                                        + ' at '
     C                                        + %Trim(%EditC($PUnq#:'Z'))
     C                   endif
     C*
     C*
     C     EndBar10      endsr

