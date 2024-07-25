     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  APICVTSLT   API to covert scanned slot - Strano Sysco Version
     F*  20 February 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    02/20/01  DAS  4.15
     F*      - Created Strano Sysco version
     F*
     F*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  Notes
     C*
     C*    This program is called from RF programs that allow the
     C*    scanning of a slot. In most situations there is nothing extra
     C*    that need to be done. However, in some situations, a client
     C*    may need to revise this program in order to add hyphens to
     C*    the scanned slot number.
     C*
     C*    Any program calling this API allows the repositioning of
     C*    the cursor within the slot entry field. This would be used
     C*    when a user must do a double scan to get the complete slot
     C*    number. For example, the first scan would get the aisle and
     C*    location. The second scan would get the level and handstack.
     C*    In that situation, you would want to identify that only the
     C*    first part of the slot was scanned and then reposition the
     C*    cursor just after those characters, waiting for the second
     C*    scan.
     C*
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PSlot     Slot number entered on screen
     C*      $PRow      Row position of slot on input screen.
     C*      $PCol      Column position of slot on input screen.
     C*
     C*    Returned Parameters
     C*      $PSlot     Converted slot (optional)
     C*      $PRow      Row to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PCol      Column to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PReturn   *OK       Everything is ok. Move on.
     C*                 *REDSPLY  Redisplay with cusor positioning.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PSlot           12
     C                   PARM                    $PRow             3 0
     C                   PARM                    $PCol             3 0
     C                   PARM                    $PReturn          8

     C*----------------------------------------------------------------
     C* Main line
415 AC*
415 AC*  Add hyphens to slot, if needed.
415 AC*
415 AC*     Add hyphens if slot doesn't already contain them.
415 AC*
     C                   if        %Scan('-':$PSlot) = 0
     C                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
     C                                      %Subst($PSlot:3:2) + '-' +
     C                                      %Subst($PSlot:5:6)
     C                   endif
     C*
     C*  Don't need to position cursor so set Row/Col to zero.
     C*
     C                   eval      $PRow = 0
     C                   eval      $PCol = 0
     C*
     C                   eval      $PReturn = '*OK'
     C                   Return
