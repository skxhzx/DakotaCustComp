     F*----------------------------------------------------------------
     F*   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  APICVTITM   API to covert scanned item
     F*  18 July 2002
     F*  Max Blacknik
     F*
     F*  Revisions
     F*
416 AF*    07/18/02  MLB  4.16
     F*      - Created.
500aAF*    03/16/05  RH   5.00a
     F*      - Enh: Revised program to add support for Client id
     F*
     F*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  Notes
     C*
     C*    This program is setup to do nothing as the default.  If a
     C*    client needs the funcion provided by this program, then do the
     C*    following:
     C*      1. Comment out the line marked w/ Dft in column 1-3.
     C*      2. Activate the 2 lines marked w/ RR and adjust the
     C*         substring positions to meet the needs of the client.
     C*      3. Re-compile the program.
     C*
     C*    This program is called from RF programs that allow the
     C*    scanning of a item. In most situations there is nothing extra
     C*    that need to be done. However, in some situations, a client
     C*    may need to revise this program in order to extract the item
     C*    the scanned in value.
     C*
     C*    Any program calling this API allows the repositioning of
     C*    the cursor within the item entry field. This would be used
     C*    when a user must do a double scan to get the complete item
     C*    number.
     C*
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $Pitem     Scanned in value entered on screen.
     C*      $PRow      Row position of item on input screen.
     C*      $PCol      Column position of item on input screen.
     C*
     C*    Returned Parameters
     C*      $PItem     Converted item (optional)
     C*      $PRow      Row to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PCol      Column to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PReturn   *OK       Everything is ok. Move on.
     C*                 *REDSPLY  Redisplay with cusor positioning.
     C*
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
500aAD @getcl          c                   const('GETCLIENT')
500aAD*
500aA /COPY QCOPYSRC,ID#JORDANO
     *----------------------------------------------------------------
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $Pitem           15
     C                   PARM                    $PRow             3 0
     C                   PARM                    $PCol             3 0
     C                   PARM                    $PReturn          8

     C*----------------------------------------------------------------
     C* Main line
     C*
     C*
     C*  Determine if item # or license # entered.
     C*
     C                   select
Dft  C                   when      $PItem > *blanks
500a C                   select
500a C                   when      client = 'JORDANOS'
500a C                   eval      $PItem = %trim($PItem)
500a C                   endsl
RR   C*                  when      %Subst($PItem:9:7) > *blanks
RR   C*                  eval      $PItem = %subst($PItem:8:8)
     C*
     C*    A vigo license plate is 15 char, same as our item #.
     C*    A vigo item number is 8 char.
     C*    A vigo license contains item number in pos 8 - 15.
     C*    If pos 9-15 are not blank, then assume vigo license.
     C*
     C                   eval      $PReturn = '*OK'
     C                   eval      $PRow = 0
     C                   eval      $PCol = 0
     C                   other
     C*
     C*  Don't need to position cursor so set Row/Col to zero.
     C*
     C                   eval      $PRow = 0
     C                   eval      $PCol = 0
     C                   eval      $PReturn = '*OK     '
     C                   endsl
     C*
     C                   Return
     *----------------------------------------------------------------
     *
500a *  *INZSR  Initialization subrotine
     *
500a C     *inzsr        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
500aA*
500a C                   endsr
500a *
     *----------------------------------------------------------------
