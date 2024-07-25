     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  APICVTSLT   API to covert scanned slot
     F*  22 June 2000
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
414 AF*    06/22/00  DAS  4.14
     F*      - Revised to add hyphens to slot number.
     F*      - Revised to reposition if length of slot <= 5.
     F*
CHY AF*    07/25/00  DAS  CHY
     F*      - Revised to add 1 to column position if = 5.
     F*        This was done because Symbol scanners only scan into
     F*        the first position of a field instead of where the
     F*        cursor lies. Therefore, in order to do double scanning
     F*        the slot field had to be split into two parts with 1
     F*        character inbetween.
     F*
CHY AF*    08/02/00  DAS  CHY2
     F*      - Revised to remove imbedded blanks from slot number.
     F*        This was done because Symbol scanners would not allow
     F*        overflowing to second fields. Therefore, we needed to
     F*        make the first field 7-characters in order to accommodate
     F*        a single scan.
     F*      - Revised to add 3 to column position if = 5.
     F*
     F*----------------------------------------------------------------

     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program is called from RF programs that allow the
     F*    scanning of a slot. In most situations there is nothing extra
     F*    that need to be done. However, in some situations, a client
     F*    may need to revise this program in order to add hyphens to
     F*    the scanned slot number.
     F*
     F*    Any program calling this API allows the repositioning of
     F*    the cursor within the slot entry field. This would be used
     F*    when a user must do a double scan to get the complete slot
     F*    number. For example, the first scan would get the aisle and
     F*    location. The second scan would get the level and handstack.
     F*    In that situation, you would want to identify that only the
     F*    first part of the slot was scanned and then reposition the
     F*    cursor just after those characters, waiting for the second
     F*    scan.
     F*
     F*----------------------------------------------------------------

     D*----------------------------------------------------------------
     D*  Variable definitions
     D*----------------------------------------------------------------
CHY2AD A12A            S              1A   Dim(12)
CHY2AD A12B            S              1A   Dim(12)
CHY2AD Forever         S              1S 0
CHY2AD I               S              3P 0
CHY2AD J               S              3P 0
     D SlotLength      S              3P 0

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
CHY2AC*
CHY2AC*  Remove imbeded blanks from slot number.
CHY2AC*
CHY2AC                   movea     $PSlot        A12A
CHY2AC                   movea     *Blanks       A12B
CHY2AC                   eval      J = 0
CHY2AC     1             do        12            I
CHY2AC                   if        A12A(I) <> ' '
CHY2AC                   eval      J = J + 1
CHY2AC                   eval      A12B(J) = A12A(I)
CHY2AC                   endif
CHY2AC                   enddo
CHY2AC                   movea     A12B          $PSlot
414 AC*
414 AC*  First check length. If <= 5 the reposition.
414 AC*
     C                   eval      SlotLength = %Len(%Trim($PSlot))
     C                   if        SlotLength <= 5
     C                   eval      $PCol = $PCol + SlotLength
CHY AC                   if        SlotLength = 5
CHY1DC***                eval      $PCol = $PCol + 1
CHY1MC                   eval      $PCol = $PCol + 3
CHY AC                   endif
     C                   eval      $PReturn = '*REDSPLY'
     C                   goto      Bottom
     C                   endif
414 AC*
414 AC*  Add hyphens to slot, if needed.
414 AC*
414 AC*     Add hyphens if slot doesn't already contain them.
414 AC*
     C                   if        %Scan('-':$PSlot) = 0
     C                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
     C                                      %Subst($PSlot:3:3) + '-' +
     C                                      %Subst($PSlot:6:5)
     C                   endif
     C*
     C*  Don't need to position cursor so set Row/Col to zero.
     C*
     C                   eval      $PRow = 0
     C                   eval      $PCol = 0
     C*
     C                   eval      $PReturn = '*OK'
     C     Bottom        Tag
     C                   Return
